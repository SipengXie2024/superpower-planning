# perf Commands Quick Reference

> This file is a cheat sheet for quick command lookup. If this is your first time,
> read SKILL.md first — it explains the seven-phase optimization cycle that gives
> these commands their context and sequence.

## Setup

```bash
# Enable perf on restricted kernels (EC2, etc.)
sudo sysctl kernel.perf_event_paranoid=-1

# Verify perf works
perf stat -- echo hello
```

## Recording

```bash
# Standard CPU profile with call graph
perf record -g --call-graph dwarf -F 997 -- <command>

# Software-only (when hardware PMU unavailable)
perf record -g --call-graph dwarf -F 997 -e cpu-clock -- <command>

# Record specific events
perf record -e cache-misses,branch-misses -g -- <command>

# Record a running process
perf record -g --call-graph dwarf -F 997 -p <pid> -- sleep 10
```

## Analysis

```bash
# Top-down report (self time, not inclusive)
perf report --sort=dso,symbol --no-children

# Instruction-level hotspot in a function
perf annotate --symbol=<function_name>

# Flat list sorted by overhead
perf report --stdio --sort=overhead

# Filter by DSO (shared library / binary)
perf report --dso=<binary_name>
```

## Hardware Counters

```bash
# General stats
perf stat -- <command>

# Cache analysis
perf stat -e cache-references,cache-misses,L1-dcache-loads,L1-dcache-load-misses -- <command>

# Branch analysis
perf stat -e branches,branch-misses -- <command>

# IPC (instructions per cycle)
perf stat -e instructions,cycles -- <command>

# Full Top-Down analysis (Intel only)
perf stat --topdown -- <command>
```

## Flame Graphs

```bash
# Using cargo-flamegraph (Rust)
cargo install flamegraph
cargo flamegraph --bench <name> -- <args>

# Using perf + Brendan Gregg's scripts
perf record -g --call-graph dwarf -F 997 -- <command>
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

## Common Gotchas

| Problem | Fix |
|---|---|
| "Permission denied" | `sudo sysctl kernel.perf_event_paranoid=-1` |
| No symbols, only addresses | Build with debug info (`-g` in CFLAGS, `debug = true` in Cargo.toml profile) |
| `[unknown]` in report | Missing DWARF info; try `--call-graph fp` instead of `dwarf` |
| Profile dominated by idle/sleep | Use wall-clock instrumentation for the compute section instead |
| Inlining hides callers | Build with `lto = false` temporarily, or use `#[inline(never)]` on suspect functions |

## Interpreting Output

**perf report columns:**
- `Overhead` (default): inclusive time — includes callees. Misleading for callers of heavy functions.
- `Self` (`--no-children`): self time only — where CPU *actually* spends cycles. Use this.
- `Children`: inclusive time. Skip this column for bottleneck identification.

**perf annotate colors:**
- Red/hot instructions: where the CPU is actually stalled
- Look for: memory loads (mov from memory), division, branch misses, unaligned access

**perf stat key ratios:**
- IPC < 1.0: memory-bound or stalled
- Cache miss rate > 10%: data layout problem
- Branch miss rate > 5%: branch-heavy code
