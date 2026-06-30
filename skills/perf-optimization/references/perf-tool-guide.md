# Linux perf — Tool Reference

> **This is a deep reference for the perf CLI tool.** Read this when you need to
> understand a specific perf feature (TMA, c2c, Intel PT, lock contention, etc.)
> beyond what the main SKILL.md and `perf-commands.md` cover.
>
> **Table of contents:**
> - Installation & Setup (line ~15)
> - Core Workflow: list → stat → record → report → annotate → top (line ~35)
> - Interpreting perf stat / IPC Guide (line ~105)
> - Optimization Decision Tree (line ~135)
> - Top-Down Microarchitecture Analysis / TMA (line ~175)
> - Flame Graphs (line ~265)
> - Memory Profiling: cache miss, false sharing (c2c), NUMA (line ~285)
> - Off-CPU Analysis (line ~365)
> - Lock Contention Analysis (line ~395)
> - Scheduler Analysis (line ~435)
> - System Call Tracing (line ~450)
> - Dynamic Probes (line ~465)
> - Intel Processor Trace (line ~490)
> - Benchmarking (perf bench) (line ~545)
> - Comparing Results (perf diff) (line ~565)
> - Event Modifiers & Advanced Syntax (line ~580)
> - Scripting & Automation (line ~610)
> - Common Optimization Patterns (line ~635)
> - Common Mistakes & Pitfalls (line ~695)
> - Security Model (line ~710)
> - Glossary (line ~790)
>
> The `github_docs/` subdirectory contains per-subcommand reference docs from the
> Linux kernel source (perf-stat, perf-record, perf-report, perf-c2c, etc.).

Comprehensive reference for Linux `perf` (Performance Counters for Linux) — professional-grade CPU profiling, performance analysis, and system optimization.

**Sources:** Linux kernel source (`tools/perf`), kernel.org perf-security documentation, Perf Wiki (perfwiki.github.io)

---

## Installation & Setup

```bash
# Ubuntu/Debian
sudo apt-get install linux-tools-common linux-tools-$(uname -r)

# RHEL/CentOS/Fedora
sudo yum install perf    # or: sudo dnf install perf

# Build from source (latest features)
sudo apt-get install build-essential libelf-dev libdw-dev binutils-dev \
  libaudit-dev libtraceevent-dev systemtap-sdt-dev libunwind-dev \
  libslang2-dev libperl-dev libzstd-dev libbabeltrace-ctf-dev flex bison
git clone https://git.kernel.org/pub/scm/linux/kernel/git/perf/perf-tools-next.git/
cd perf-tools-next && make -C tools/perf install

# Verify installation
perf --version
perf test    # Run self-tests
```

### Permissions (Critical — Most Common Setup Issue)

```bash
# Check current paranoid level
cat /proc/sys/kernel/perf_event_paranoid

# Development: temporarily allow full access
sudo sysctl -w kernel.perf_event_paranoid=-1

# Production: use CAP_PERFMON (Linux 5.9+, recommended)
sudo setcap "cap_perfmon,cap_sys_ptrace,cap_syslog=ep" $(which perf)

# Persistent: /etc/sysctl.d/99-perf.conf
# kernel.perf_event_paranoid = -1
# kernel.perf_event_mlock_kb = 2048
```

| paranoid | Scope | Use Case |
|----------|-------|----------|
| `-1` | Unrestricted | Development only |
| `0` | Per-process + system-wide, no raw tracepoints | Trusted users |
| `1` | Per-process only (default) | Multi-user systems |
| `2` | User-space only | Restricted environments |

---

## Core Workflow (80% of Use Cases)

### Step 1: List Available Events

```bash
perf list                     # All events
perf list hw                  # Hardware: cycles, instructions, cache-misses...
perf list sw                  # Software: context-switches, page-faults...
perf list cache               # Cache: L1-dcache-loads, LLC-load-misses...
perf list tracepoint          # Kernel tracepoints: sched, block, net...
perf list <keyword>           # Search by keyword
```

### Step 2: Count Events (perf stat)

```bash
perf stat ./program                    # Default counters (cycles, instructions, IPC...)
perf stat -d ./program                 # Detailed (+ cache, branch stats)
perf stat -dd ./program                # Very detailed
perf stat -ddd ./program               # Maximum detail
perf stat -e cycles,instructions,cache-misses,branch-misses ./program  # Custom events
perf stat -r 5 ./program               # Repeat 5x, show mean ± stddev
perf stat -I 1000 ./program            # Print every 1 second (interval mode)
perf stat -a sleep 10                  # System-wide for 10 seconds
perf stat -p <PID>                     # Attach to running process
perf stat -C 0,1 sleep 5              # Specific CPUs only
```

### Step 3: Sample-Based Profiling (perf record)

```bash
perf record ./program                     # Default: cycles @ 4000 Hz
perf record -F 999 ./program              # Custom frequency (use odd numbers to avoid lockstep)
perf record -g ./program                  # Call graphs via frame pointer (fastest)
perf record --call-graph dwarf ./program  # DWARF unwinding (most reliable, ~10% overhead)
perf record --call-graph lbr ./program    # LBR-based (Intel only, lowest overhead)
perf record -a sleep 30                   # System-wide 30 seconds
perf record -p <PID> sleep 60            # Attach to process for 60 seconds
perf record -e cache-misses -g ./program  # Profile specific events
perf record -o myfile.data ./program      # Custom output filename
```

### Step 4: Analyze (perf report)

```bash
perf report                                  # Interactive TUI browser
perf report --stdio                          # Text output (for piping/scripting)
perf report --sort comm,dso,symbol           # Group by process, library, function
perf report --no-children                    # Self cost only (don't accumulate callees)
perf report --percent-limit 2               # Show only ≥2% overhead
perf report -s sym,srcline                  # Source line info (needs debuginfo)
perf report -g folded                        # Compact call chain format
perf report --hierarchy                      # Hierarchical grouping
perf report --header                         # Show system info header
```

### Step 5: Annotate Source Code

```bash
perf annotate <symbol>                  # Assembly + source annotation
perf annotate -M intel <symbol>         # Intel syntax (vs. default AT&T)
perf annotate --stdio <symbol>          # Text output
```

### Step 6: Live Monitoring

```bash
perf top                        # System-wide live (like top for CPU functions)
perf top -p <PID>               # Process-specific
perf top -e cache-misses        # Monitor specific event
perf top -g                     # With call graphs
```

---

## Interpreting perf stat Output (IPC Guide)

**IPC (Instructions Per Cycle)** is the single most important metric for initial diagnosis:

```
Performance counter stats for './my_program':
     42,301,302,041  cycles
     63,451,953,062  instructions  #  1.50  insn per cycle    ← IPC
```

| IPC Range | Diagnosis | Next Step |
|-----------|-----------|-----------|
| **> 3.0** | Excellent throughput | If still slow → algorithm is the bottleneck, reduce work |
| **1.5 – 3.0** | Good, near optimal | Profile with `perf record -g` to find remaining hotspots |
| **0.5 – 1.5** | Moderate stalls | `perf stat --topdown` → identify frontend/backend/speculation |
| **< 0.5** | Severely stalled | Likely memory-bound → check cache misses, NUMA, I/O |
| **Very high IPC + slow** | Doing too much work | Algorithm optimization needed, not hardware tuning |
| **Very low IPC + slow** | Pipeline bottleneck | Hardware-level issue: caches, branches, or resource stalls |

**Other key ratios from `perf stat -d`:**

| Metric | Healthy | Concerning |
|--------|---------|------------|
| Cache miss rate (LLC) | < 5% | > 20% |
| Branch miss rate | < 2% | > 5% |
| Context switches/sec | < 10K | > 100K |
| CPU migrations/sec | < 100 | > 1K |

---

## Optimization Decision Tree

```
"My program is slow"
│
├─→ perf stat ./program → Check IPC
│
├─→ Low IPC (< 1.0)? → Pipeline is stalled
│   └─→ perf stat --topdown ./program
│       ├─→ Backend Bound (largest)?
│       │   ├─→ Memory Bound → Cache misses, NUMA issues
│       │   │   └─→ perf stat -d ./prog   (check L1/LLC miss rates)
│       │   │       └─→ perf mem record / perf c2c record
│       │   └─→ Core Bound → Execution port saturation, long-latency ops
│       │       └─→ perf stat -M tma_core_bound_group ./prog
│       │
│       ├─→ Frontend Bound (largest)?
│       │   ├─→ Fetch Latency → I-cache misses, iTLB misses
│       │   │   └─→ perf stat -e L1-icache-load-misses ./prog
│       │   └─→ Fetch Bandwidth → Decoder bottleneck
│       │       └─→ Consider code layout optimization, PGO, BOLT
│       │
│       └─→ Bad Speculation (largest)?
│           └─→ Branch mispredictions
│               └─→ perf stat -e branch-misses ./prog
│                   └─→ perf record -e branch-misses -b -g ./prog
│
├─→ High IPC (> 2.0) but slow? → Doing too much work
│   └─→ perf record -g ./prog → perf report
│       └─→ Find hotspot functions → perf annotate <func>
│           └─→ Algorithmic optimization (reduce instructions)
│
└─→ Moderate IPC but slow? → Mixed or I/O bound
    ├─→ perf trace -s ./prog → Check syscall time (I/O bound?)
    ├─→ perf sched latency → Check scheduling overhead
    └─→ Off-CPU analysis → See Off-CPU section below
```

---

## Top-Down Microarchitecture Analysis (TMA)

The **recommended starting approach** for any performance investigation on Intel CPUs.

### TMA Hierarchy (Full Tree)

```
TopdownL1
├── Retiring          (useful work)
│   ├── Heavy Operations    (microcode assists, FP divides)
│   └── Light Operations    (simple ALU, loads/stores)
├── Bad Speculation   (wasted work)
│   ├── Branch Mispredicts
│   └── Machine Clears      (memory ordering, FP assists)
├── Frontend Bound    (instruction supply)
│   ├── Fetch Latency        (i-cache miss, iTLB miss, MSROM)
│   └── Fetch Bandwidth      (decoder, DSB coverage)
└── Backend Bound     (execution)
    ├── Memory Bound
    │   ├── L1 Bound         (DTLB miss, store forwarding, lock penalty)
    │   ├── L2 Bound
    │   ├── L3 Bound
    │   ├── DRAM Bound       (memory bandwidth, NUMA)
    │   └── Store Bound
    └── Core Bound
        ├── Divider           (division/sqrt operations)
        └── Ports Utilization (execution port saturation)
```

### Step-by-Step Workflow

```bash
# Level 1: identify the category
perf stat --topdown ./my_program
# Output example:
#   retiring  bad spec  frontend  backend
#    25.5%      6.0%     24.3%     44.3%   ← Backend Bound is largest

# Level 2: drill into the largest category
perf stat -M tma_backend_bound_group ./my_program
# → tma_core_bound: 24.9%, tma_memory_bound: 17.5%

# Level 3: drill deeper
perf stat -M tma_memory_bound_group ./my_program
# → tma_l1_bound, tma_l2_bound, tma_l3_bound, tma_dram_bound

# Avoid multiplexing: measure one metric at a time
perf stat -M tma_l3_bound ./my_program

# Locate the bottleneck in code (check "Sample with:" in perf list)
perf record -e MEM_LOAD_RETIRED.L3_MISS -g ./my_program
perf report
```

### Multiplexing Warning

When you see percentages like `(34.73%)` in perf stat output, it means the kernel is time-multiplexing events (not enough hardware counters). Results are **estimated**, not exact. Workaround: measure fewer events per run, or use `--metric-no-group`.

### TopDown via RDPMC (In-Application, Ice Lake+)

```c
#include <x86intrin.h>
#define RDPMC_FIXED  (1 << 30)
#define RDPMC_METRIC (1 << 29)
#define GET_METRIC(m, i) (((m) >> (i*8)) & 0xff)

uint64_t slots   = _rdpmc(RDPMC_FIXED | 3);   // Pipeline slots
uint64_t metrics = _rdpmc(RDPMC_METRIC | 0);   // TopDown metrics

// L1: each 8-bit field, sum = 0xff (100%)
float retiring = (float)GET_METRIC(metrics, 0) / 0xff;
float bad_spec = (float)GET_METRIC(metrics, 1) / 0xff;
float fe_bound = (float)GET_METRIC(metrics, 2) / 0xff;
float be_bound = (float)GET_METRIC(metrics, 3) / 0xff;

// L2 (Sapphire Rapids+): indices 4-7
// heavy_ops, br_mispredict, fetch_lat, mem_bound
// Derived: light_ops = retiring - heavy_ops
//          machine_clears = bad_spec - br_mispredict
//          fetch_bw = fe_bound - fetch_lat
//          core_bound = be_bound - mem_bound
```

**Important:** Reset counters periodically (`ioctl(fd, PERF_EVENT_IOC_RESET, 0)`) or use `-I` interval mode to maintain 8-bit precision.

---

## Flame Graphs

```bash
# Record with call graphs (pick ONE call-graph method)
perf record -F 99 -g ./my_program                    # Frame pointer (default)
perf record -F 99 --call-graph dwarf ./my_program     # DWARF (most reliable)
perf record -F 99 --call-graph lbr ./my_program       # LBR (Intel, lowest overhead)

# Built-in flame graph (Linux 5.8+)
perf script report flamegraph

# Brendan Gregg's FlameGraph (more customizable)
git clone https://github.com/brendangregg/FlameGraph
perf script | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl > flame.svg

# Firefox Profiler (interactive web UI)
perf script -F +pid --header > profile.perf
# Upload at: https://profiler.firefox.com/
```

---

## Memory Profiling

### Cache Miss Analysis

```bash
# Quick cache overview
perf stat -e cache-references,cache-misses,\
L1-dcache-load-misses,L1-dcache-loads,\
LLC-load-misses,LLC-loads ./program

# Sample on LLC misses to find hotspots
perf record -e LLC-load-misses -g ./program
perf report

# Detailed memory access profiling
perf mem record ./program              # Record memory events
perf mem report                        # Analyze
perf mem report --sort=mem             # Sort by access type (L1/L2/L3/DRAM/Remote)
```

### False Sharing Detection (perf c2c)

Cache-to-Cache analysis detects threads writing to the same cache line.

**Multi-architecture support:**
- **Intel**: load latency + precise store events (default: `ldlat=30`)
- **AMD**: IBS op PMU (not supported on Zen3)
- **ARM64**: SPE-based sampling (statistical, not every access captured)
- **PowerPC**: Random instruction sampling with thresholding

```bash
# Record (system-wide recommended)
perf c2c record -a sleep 10
perf c2c record -- -g -a ./program    # With call graphs

# Analyze
perf c2c report                       # Interactive TUI
perf c2c report --stdio               # Text output
perf c2c report --stats               # Summary statistics only
perf c2c report -d rmt                # Sort by remote HITM (cross-socket)
perf c2c report -d lcl                # Sort by local HITM (same socket)

# Key output columns:
#   Rmt HITM  - Remote cache hit-in-modified (worst: cross-socket bounce)
#   Lcl HITM  - Local cache hit-in-modified (same-socket bounce)
#   Cacheline - The contended 64-byte cache line address
#   Offset    - Byte offset within the cache line being accessed

# Tip: Use --double-cl for adjacent cacheline prefetch architectures
perf c2c report --double-cl
```

**Fix false sharing:**
```c
// Bad: fields on same cache line, written by different threads
struct shared_data {
    int counter_thread_a;  // offset 0
    int counter_thread_b;  // offset 4  ← false sharing!
};

// Good: pad to separate cache lines
struct shared_data {
    alignas(64) int counter_thread_a;
    alignas(64) int counter_thread_b;
};
```

### NUMA Analysis

```bash
perf stat -e node-loads,node-load-misses,\
node-stores,node-store-misses ./program

# Check: node-load-misses / node-loads > 20% → NUMA imbalance
# Fix: numactl --membind=0 ./program  or  numactl --interleave=all ./program
```

---

## Off-CPU Analysis

Profile time spent **waiting** (blocked, sleeping, I/O) — not just CPU time.

```bash
# Method 1: sched tracepoints
perf record -e sched:sched_switch -a sleep 10
perf script  # Shows what each task was doing when switched off-CPU

# Method 2: perf record with context-switch tracking
perf record --switch-events -g ./program
perf report  # Toggle context switches with 's' key

# Method 3: Combined on-CPU + off-CPU (wall-clock profiling)
perf record --latency -g ./program
perf report --latency
perf report --hierarchy --sort latency,parallelism,comm,symbol

# Parallelism analysis
perf report --latency --parallelism=32-64  # Filter specific parallelism levels
perf report -F time,latency,parallelism --time-quantum=1s  # Time-series view

# Method 4: perf trace for I/O-bound analysis
perf trace -s ./program
# Shows: syscall count, total time, min/max/avg per syscall
# High time in read/write/futex → I/O or lock-bound
```

---

## Lock Contention Analysis

```bash
# Quick live analysis with BPF (recommended, lowest overhead)
perf lock contention -ab sleep 5           # System-wide, all lock types
perf lock contention -abp <PID> sleep 5    # Specific process

# By stack trace: WHERE does contention happen?
perf lock con -ab sleep 5
#  contended   total wait     max wait     avg wait         type   caller

# By task: WHO is contending?
perf lock con -abt sleep 5
#  contended   total wait     max wait     avg wait          pid   comm

# By lock: WHICH lock is contended?
perf lock con -abl sleep 5
#  contended   total wait     max wait     avg wait            address   symbol

# By owner: WHO holds the lock? (v6.3+)
perf lock con -abto -Y mutex sleep 5

# Filter by lock type
perf lock con -ab -Y spinlock sleep 5
perf lock con -ab -Y mutex sleep 5
perf lock con -ab -Y rwsem sleep 5

# By cgroup (v6.7+)
perf lock con -ab --lock-cgroup sleep 5

# Without BPF (two-step, consistent results)
perf lock record -a sleep 5
perf lock contention              # Or: perf lock report
```

---

## Scheduler Analysis

```bash
perf sched record sleep 10              # Record scheduler events

perf sched latency                      # Latency summary per task
#  max/avg/total scheduling latency, number of switches

perf sched map                          # Visual CPU ↔ task mapping over time
perf sched timehist                     # Time-ordered event history
perf sched timehist -V                  # With idle stats

perf sched script                       # Raw event trace
```

---

## System Call Tracing

```bash
perf trace ./program                     # All syscalls (like strace, lower overhead)
perf trace -e open,read,write ./program  # Specific syscalls only
perf trace -p <PID>                      # Attach to running process
perf trace -a sleep 10                   # System-wide
perf trace --duration 10 ./program       # Only syscalls taking >10ms
perf trace -s ./program                  # Summary statistics (most useful!)
perf trace -T ./program                  # Show wall-clock timestamps
```

---

## Dynamic Probes

```bash
# Add probe at function entry
perf probe --add tcp_sendmsg
perf probe --add 'tcp_sendmsg size'               # Capture argument

# Add probe at specific source line (needs debuginfo)
perf probe -s /path/to/src --add 'net/ipv4/tcp.c:1234 sk->sk_state'

# Add return probe
perf probe --add 'tcp_sendmsg%return $retval'

# List / delete probes
perf probe --list
perf probe --del 'probe:tcp_sendmsg'

# Record and analyze
perf record -e probe:tcp_sendmsg -aR sleep 5
perf script
```

---

## Intel Processor Trace (Intel PT)

Hardware control flow tracing (Broadwell+). Records every branch — instruction-level visibility.

**Warning:** Generates **hundreds of MB/s per CPU**. Always use data reduction strategies.

```bash
# Check support
ls /sys/devices/intel_pt/ && echo "Supported"

# Setup (may need elevated privileges)
sudo setcap "cap_ipc_lock,cap_sys_ptrace,cap_sys_admin,cap_syslog=ep" $(which perf)
```

### Recording

```bash
# Basic (user-space only)
perf record -e intel_pt//u ./program

# Cycle-accurate timing
perf record -e intel_pt/cyc,noretcomp/u ./program

# Filter to specific function (massive data reduction)
perf record -e intel_pt//u --filter 'filter main @ ./program' ./program

# Kernel-only (lower data rate)
sudo perf record -e intel_pt//k -a sleep 5

# Snapshot mode (capture on demand)
perf record -Se intel_pt// ./program &
kill -USR2 $!    # Trigger snapshot capture
```

### Analysis

```bash
perf script --call-trace                         # Function call tree
perf script --call-ret-trace                     # With function latencies
perf script --insn-trace --xed -F+srcline        # Instruction trace + source
perf script --time 1.5-2.0 --cpu 0              # Selective decode (save time)

# Export to SQLite database
perf script -s export-to-sqlite.py perf_data.db
python3 exported-sql-viewer.py perf_data.db      # GUI call graph viewer

# Power/frequency monitoring
sudo perf record -a -e intel_pt/branch=0/,power:cpu_idle sleep 1
perf script --itrace=ep -F-ip --ns
```

| Data Reduction Strategy | Method | Effectiveness |
|------------------------|--------|---------------|
| Address filter | `--filter 'filter func @ binary'` | Very High |
| Snapshot mode | `-S`, trigger with `kill -USR2` | Very High |
| Kernel-only | `-e intel_pt//k` | High |
| Short duration | Minimize recording time | High |
| Selective decode | `--time A-B --cpu X` in perf script | Post-hoc |

---

## Benchmarking (perf bench)

```bash
perf bench mem memcpy              # memcpy throughput
perf bench mem memset              # memset throughput
perf bench sched messaging         # IPC messaging (pipe/socket)
perf bench sched messaging -g 64   # 64 process groups
perf bench sched pipe              # Context switch via pipe
perf bench numa mem -p 4 -t 4     # NUMA memory access (4 procs × 4 threads)
perf bench futex hash              # Futex hash table
perf bench futex wake              # Futex wake latency
```

---

## Comparing Results (perf diff)

```bash
perf record -o baseline.data ./program_v1
perf record -o optimized.data ./program_v2
perf diff baseline.data optimized.data          # Side-by-side comparison
perf diff -c ratio baseline.data optimized.data # Ratio for scalability

# Compare hot code regions using LBR
perf record -b -o v1.data ./prog_v1
perf record -b -o v2.data ./prog_v2
perf diff --stream v1.data v2.data
```

---

## Event Modifiers & Advanced Syntax

```bash
# Scope modifiers
perf stat -e cycles:u ./cmd       # User-space only
perf stat -e cycles:k ./cmd       # Kernel-space only
perf stat -e cycles:uk ./cmd      # Both
perf stat -e cycles:h ./cmd       # Hypervisor events

# Precision modifiers (reduce skid — distance from trigger to sample IP)
perf record -e cycles:p ./cmd     # Precise (some skid)
perf record -e cycles:pp ./cmd    # Very precise (PEBS/IBS)
perf record -e cycles:ppp ./cmd   # Maximum precision

# Event groups (scheduled together for accurate ratios)
perf stat -e '{cycles,instructions}' ./cmd
perf record -e '{cycles,instructions}:S' ./cmd   # :S = sample on first only

# Raw PMU events (from CPU vendor manual)
perf stat -e r00c0 ./cmd                                  # Raw hex encoding
perf stat -e cpu/event=0xc0,umask=0x00/ ./cmd             # Named fields
perf record -e cpu/cpu-cycles,period=100001/ ./cmd         # Custom period

# Multiplexing formula (when events exceed hardware counters):
# final_count = raw_count × (time_enabled / time_running)
```

---

## Scripting & Automation

```bash
# Machine-readable outputs
perf stat -x\; ./program 2>&1                      # CSV with ; delimiter
perf stat --json ./program                          # JSON output
perf stat record ./program && perf stat report      # Save + replay stat

# Custom perf script fields
perf script -F event,ip,sym,time,cpu,period         # Select fields
perf script -F +metric                              # Add metric calculations

# Generate script template for custom processing
perf script -g python    # → generates perf-script.py template
perf script -g perl      # → generates perf-script.pl template

# Time-based filtering
perf report --time 5.0-10.0                         # Seconds 5 to 10
perf report --cpu 0,1,2                             # Specific CPUs
perf report --socket-filter 0                       # NUMA socket 0
```

---

## Common Optimization Patterns

### High Cache Miss Rate

```bash
# Diagnose
perf stat -e L1-dcache-load-misses,L1-dcache-loads,LLC-load-misses,LLC-loads ./cmd
# Concerning: LLC miss rate > 5%, L1 miss rate > 10%

# Locate
perf record -e LLC-load-misses -g ./cmd && perf report
```

**Fixes:** improve data locality (SoA vs AoS), reduce working set, `__builtin_prefetch()`, cache-line align hot data, batch processing

### Branch Misprediction

```bash
# Diagnose
perf stat -e branches,branch-misses ./cmd
# Concerning: miss rate > 2-3%

# Locate
perf record -e branch-misses -b -g ./cmd && perf report --branch-history
```

**Fixes:** branchless code (`cmov`), sort data for predictable patterns, `__builtin_expect()`, reduce branch nesting in hot loops

### False Sharing

```bash
perf c2c record -a ./cmd && perf c2c report
# Look for high Rmt/Lcl HITM on specific cache lines
```

**Fixes:** `alignas(64)` on per-thread data, pad structures, thread-local storage, reduce write frequency

### Context Switch Overhead

```bash
perf stat -e context-switches,cpu-migrations ./cmd
perf sched record ./cmd && perf sched latency
```

**Fixes:** `taskset` / `pthread_setaffinity_np`, reduce lock contention, lock-free data structures, batch work

### I/O Bound

```bash
perf trace -s ./cmd   # Check: high time in read/write/epoll/futex?
```

**Fixes:** async I/O (`io_uring`), batch I/O ops, memory-mapped files, connection pooling

---

## Common Mistakes & Pitfalls

| Mistake | Symptom | Fix |
|---------|---------|-----|
| No call graphs | Flat profile, can't see callers | Add `-g` or `--call-graph dwarf` to `perf record` |
| Frame pointer stripped | Call graphs show `[unknown]` | Build with `-fno-omit-frame-pointer` or use `--call-graph dwarf` |
| Missing debuginfo | No source lines in `perf annotate` | Install `*-dbgsym` packages or build with `-g` |
| Profiling too short | Noisy/unreliable data | Run longer, or use `perf stat -r 5` for statistical confidence |
| Too many events | Multiplexing distorts counts | Reduce events per run; check for `(xx.xx%)` in output |
| Permission denied | `perf record` fails silently | Set `perf_event_paranoid=-1` or use `CAP_PERFMON` |
| Wrong frequency | Overhead too high or samples too few | `-F 99` (low overhead) to `-F 9999` (high detail) |
| Perf version mismatch | Missing features, cryptic errors | `perf --version` must match kernel: `uname -r` |
| Not using odd freq | Samples align with periodic code | Use odd numbers: `-F 99`, `-F 997`, not `-F 100` |
| Ignoring `--exclude-perf` | Perf profiling itself | Add `--exclude-perf` to remove perf overhead from results |

---

## Security Model (Production)

### Capabilities (Linux 5.9+)

| Capability | Purpose |
|------------|---------|
| `CAP_PERFMON` | Core performance monitoring (use this!) |
| `CAP_SYS_PTRACE` | Cross-process monitoring |
| `CAP_SYSLOG` | Read kernel addresses from /proc/kallsyms |
| `CAP_IPC_LOCK` | Bypass perf_event_mlock_kb limits |

```bash
# Production setup: capability-based access control
sudo groupadd perf_users
sudo chgrp perf_users $(which perf)
sudo chmod o-rwx $(which perf)
sudo setcap "cap_perfmon,cap_sys_ptrace,cap_syslog=ep" $(which perf)
sudo usermod -aG perf_users $USER

# Resource limits (/etc/security/limits.conf):
# @perf_users  hard  nofile   131072    # File descriptors (1 per event×CPU)
# @perf_users  hard  memlock  2097152   # Memory for ring buffers (KB)
```

### perf_event_open() Kernel API

The underlying syscall for all perf operations:

```c
int perf_event_open(struct perf_event_attr *attr,
                    pid_t pid, int cpu, int group_fd, unsigned long flags);
// pid=0, cpu=-1  → current task, any CPU (per-task counter)
// pid=-1, cpu=X  → all tasks on CPU X (per-CPU counter, needs CAP_PERFMON)
// pid>0, cpu=-1  → specific task, any CPU
// group_fd=-1    → new group leader; group_fd=N → join existing group
```

---

## Ftrace Integration

```bash
perf ftrace trace -T func_name ./program            # Function trace
perf ftrace trace -G func_name ./program            # Function graph (call tree + timing)
perf ftrace latency -T func_name -a sleep 5         # Function latency histogram
```

---

## Tips (Organized by Category)

**Recording:**
- Use odd sampling frequencies (`-F 99`, not `-F 100`) to avoid lockstep with periodic code
- `perf record -B` skips build-id collection for faster recording
- `perf record --exclude-perf` removes perf's own overhead from samples
- `perf record -u <user>` records all processes by a specific user
- `-I` in `perf record` captures register values, visible in sample context

**Analysis:**
- `perf report --sort comm,dso` for a high-level overview
- `perf report --no-children` for self-cost without callee accumulation
- `perf report --percent-limit 5` hides noise below 5%
- `perf report -s sym,srcline` shows source lines (needs debuginfo)
- `perf report --time X-Y --cpu A,B` for time and CPU filtering

**Metrics:**
- `perf stat -I 1000` prints counters every second for time-series analysis
- `perf record -e '{cycles,instructions}:S'` then `perf script -F +metric` computes IPC per sample
- `perf stat -x\;` for machine-readable CSV output (pipe to scripts)
- `perf stat --json` for structured JSON output

**Call Graphs:**
- Call chains broken? Try `--call-graph dwarf` (most compatible)
- Stitch LBR entries: `perf record --call-graph lbr; perf report --stitch-lbr`
- Show inline functions: `perf report --inline`

**Intel PT:**
- `perf record -e intel_pt//; perf script --call-trace` for function-level trace
- `perf script --call-ret-trace` for function latency measurement
- `perf record --filter 'filter func @ prog' -e intel_pt//u ./prog` for single function trace

---

## Glossary

| Term | Definition |
|------|-----------|
| **PMU** | Performance Monitoring Unit — hardware counters in CPU |
| **PEBS** | Processor Event-Based Sampling (Intel) — precise sampling with low skid |
| **IBS** | Instruction-Based Sampling (AMD) — equivalent of PEBS |
| **SPE** | Statistical Profiling Extension (ARM) — hardware precise sampling |
| **HITM** | Hit-In-Modified — load hitting a modified cache line (sharing indicator) |
| **C2C** | Cache-to-Cache — tool for detecting false sharing |
| **TMA** | Top-down Microarchitecture Analysis — systematic bottleneck methodology |
| **IPC** | Instructions Per Cycle — primary throughput indicator |
| **Skid** | Distance between sample IP and actual event trigger point |
| **Multiplexing** | Kernel time-sharing when events exceed hardware counters |
| **LBR** | Last Branch Record — hardware branch history buffer |
| **TPEBS** | Timed PEBS — retirement latency info (Granite Rapids+) |
| **Off-CPU** | Time spent not on CPU (blocked, sleeping, waiting for I/O) |
| **Uncore** | Components outside CPU cores (LLC, memory controller, etc.) |
| **MPKI** | Misses Per Kilo Instructions — normalized miss rate |
| **DSB** | Decoded Stream Buffer — Intel micro-op cache |
| **ROB** | Reorder Buffer — tracks in-flight instructions in OoO CPUs |
| **NUMA** | Non-Uniform Memory Access — multi-socket memory topology |

---

## Reference

- **Perf Wiki**: https://perfwiki.github.io/main/
- **Kernel Source**: https://github.com/torvalds/linux/tree/master/tools/perf
- **Security Docs**: https://www.kernel.org/doc/html/latest/admin-guide/perf-security.html
- **Brendan Gregg**: https://www.brendangregg.com/perf.html
- **Mailing List**: https://lore.kernel.org/linux-perf-users/

### Learning Path

1. **Beginner**: `perf stat` → `perf record -g` → `perf report` → flame graphs
2. **Intermediate**: Top-Down TMA → `perf mem` → `perf c2c` → `perf lock`
3. **Advanced**: Intel PT → `perf probe` → Off-CPU analysis → RDPMC
4. **Expert**: `perf_event_open()` API → BPF integration → custom PMU programming

---

*Generated from Linux kernel tools/perf source, kernel.org documentation, and Perf Wiki*
