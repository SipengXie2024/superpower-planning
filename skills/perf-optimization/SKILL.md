---
name: perf-optimization
description: "Systematic performance optimization methodology: profile first, fix only the #1 bottleneck, re-profile, repeat. Use when optimizing any program's performance — before writing SIMD, parallelism, caching, or algorithmic rewrites. Also use when someone says 'make it faster', 'this is slow', 'optimize this', 'too slow', 'performance bottleneck', or wants to reduce latency/prove time/build time. Prevents the common trap of guessing bottlenecks (which wastes 10x more code for less speedup). Covers perf record/annotate workflow, A/B testing discipline, contaminated profile diagnosis, and when to stop. NOT for memory leaks (use valgrind/heaptrack) or known algorithmic complexity fixes (O(N^2) → O(N log N))."
---

# Shrink the Bottleneck Top-Down

## Overview

Performance optimization has exactly one correct workflow: **profile → fix the #1 bottleneck → re-profile → repeat**. Everything else — guessing which function is slow, fixing multiple things between profiles, assuming "this should help" — is wasted effort.

**Core principle:** Without a profile, even experienced engineers routinely misidentify the bottleneck. Measured data decides what to fix; intuition does not.

**Iron law:**

```
NO OPTIMIZATION WITHOUT A PROFILE FIRST
```

## When to Use

- Any performance complaint: "this is slow", "can we make it faster", "prove time is too long"
- Before writing SIMD, parallelism, caching, or algorithmic rewrites
- When a benchmark regresses
- When the user says "optimize"

**Use this ESPECIALLY when:**
- You think you already know what's slow (you probably don't)
- Under time pressure (guessing wastes more time than profiling)
- The codebase has multiple potential bottlenecks

**Don't skip when:**
- "It's obviously the hash function" — profile first, confirm
- "I'll just try one quick change" — that one change will be wrong 80% of the time
- "perf doesn't work on this machine" — see Fallback Profiling below

## When NOT to Use

- **Known algorithmic complexity fix** — if the problem is O(N^2) where O(N log N) exists, just change the algorithm. No need to profile; you already know the fix.
- **Memory leaks** — use valgrind `--tool=massif` or heaptrack, not perf CPU profiling.
- **I/O-bound programs** — network latency, disk wait, database queries. perf CPU profile won't show these; use `strace -T`, `perf trace`, or application-level timing.
- **Trivial known fix** — a one-line change where the cause and fix are already clear (e.g., removing an accidental `.clone()` in a hot loop). Just fix it, measure, done.
- **Build time / compile time** — use `cargo build --timings`, `cargo llvm-lines`, or `-Z time-passes`. Different tools, different methodology.

## The Cycle

```
┌─────────────┐
│  1. Profile  │◀──────────────────────────┐
└──────┬──────┘                            │
       ▼                                   │
┌─────────────┐                            │
│ 2. Identify │  Find the #1 function      │
│   top func  │  (highest % of total)      │
└──────┬──────┘                            │
       ▼                                   │
┌─────────────┐                            │
│  3. Drill   │  perf annotate: which      │
│   down      │  instruction is hottest?   │
└──────┬──────┘                            │
       ▼                                   │
┌─────────────┐                            │
│ 4. Fix ONE  │  Smallest change that      │
│   thing     │  addresses the bottleneck  │
└──────┬──────┘                            │
       ▼                                   │
┌─────────────┐     yes                    │
│ 5. A/B test │──────────┐                 │
│   measure Δ │          ▼                 │
└──────┬──────┘   ┌─────────────┐          │
       │ no       │ 6. Top func │──yes────▶│
       ▼          │   >10-15%?  │          │
   Revert.        └──────┬──────┘
   Re-think.             │ no
                         ▼
                  ┌─────────────┐
                  │  7. STOP    │
                  │  Diminishing│
                  │  returns    │
                  └─────────────┘
```

### Phase 1: Profile

**Command (Linux, works on most EC2 instances):**

```bash
# Enable perf access (needed on EC2 / restricted kernels)
sudo sysctl kernel.perf_event_paranoid=-1

# Record call-graph profile at ~1000 Hz
perf record -g --call-graph dwarf -F 997 -- <your-command>

# View top-down report
perf report --sort=dso,symbol --no-children
```

**Key flags:**
- `-g --call-graph dwarf`: full call graph with DWARF debug info (needs debug symbols)
- `-F 997`: sample at ~1000 Hz (prime number avoids aliasing with periodic events)
- `--no-children`: show self time, not inclusive time — you want to know where CPU *actually* spends cycles, not which caller triggered it

**If perf hardware PMU is unavailable** (some VMs, containers):

```bash
# Software-only fallback — less precise but still useful
perf record -g --call-graph dwarf -F 997 -e cpu-clock -- <your-command>
```

**Output you need:**
- The function name at the top of `perf report` and its percentage
- Write this down before doing anything else

**Record in `.planning/findings.md`:**
```markdown
## Perf Profile — Round N
- Date: YYYY-MM-DD
- Command: `<exact benchmark command>`
- Top function: `module::function_name` at XX.X%
- Runner-up: `module::other` at YY.Y%
```

### Phase 2: Identify the #1 Function

Look at the `perf report` output. The top function by self-time percentage is your target. Nothing else matters until this one is fixed.

**Rules:**
- Fix ONLY the #1 function. Not #2. Not #3.
- If #1 is < 10-15% and the profile is spread across many functions → you're done (see "When to Stop")
- If #1 is a library function you can't modify → find what feeds it, or find an alternative

### Phase 3: Drill Down

```bash
perf annotate --symbol=<function_name>
```

This shows which *instructions* within the function are hottest. This tells you:
- Is it a memory access pattern? (cache misses → data layout change)
- Is it a specific arithmetic op? (→ SIMD, lookup table, or algorithm change)
- Is it a branch? (→ branch-free variant, likely/unlikely hints)
- Is it a function call inside a loop? (→ inline, hoist, or batch)

### Phase 4: Fix ONE Thing

Make the smallest change that addresses the bottleneck. Common fixes by bottleneck type:

| Bottleneck Pattern | Typical Fix |
|---|---|
| Scalar loop over large array | SIMD intrinsics (SSE2/AVX2/NEON) |
| Bit manipulation in inner loop | Lookup table, PDEP/PEXT, byte-shuffle |
| Random memory access pattern | Data layout change, prefetch, cache-line alignment |
| Function call in hot loop | Inline, hoist invariant out of loop, batch |
| Redundant computation | Memoize, precompute, cache results |
| Platform-gated code (`#[cfg(...)]`) | Remove unnecessary gates, enable on all platforms |
| Lock contention | Lock-free structure, reduce critical section, partition |

**CHECKPOINT:** State what you're changing and why (one sentence), linking to the profile data. If the change is > 50 lines or touches shared abstractions, confirm with the user first.

### Phase 5: A/B Test

Run the **exact same benchmark** before and after, on the **same machine**, with the **same data**.

```bash
# Before (already recorded)
# After
cargo test --release <benchmark_name> -- --nocapture

# or
hyperfine --warmup 3 '<before-command>' '<after-command>'
```

**Report format:**
```
Round N: <function_name> (XX.X% of profile)
Fix: <one-line description>
Before: NNNms
After:  NNNms
Delta:  X.Xx speedup
```

**If no improvement or regression:** Revert immediately. The profile told you where the time goes, but your fix didn't address the real cause. Re-examine `perf annotate` output more carefully.

### Phase 6: Check if Done

After a successful fix, **re-profile from scratch** (Phase 1 again). The landscape reshuffles after every fix:
- A function at 2% before might be 28% now (because the former #1 shrank)
- A function that was invisible might surface

**Continue the cycle** until the top function is below 10-15% and the profile is spread across many functions.

### Phase 7: Stop — Diminishing Returns

When no single function dominates the profile:
- Further single-function optimization yields diminishing returns
- The remaining gains come from **architectural changes**: reducing total data, changing the algorithm, switching hardware, or restructuring the computation

**Say this explicitly to the user** — don't keep squeezing 2% improvements. Suggest the architectural levers available.

## Fallback Profiling (No perf)

When `perf` is unavailable (macOS, some containers, CI):

| Platform | Tool | Command |
|---|---|---|
| macOS | Instruments / `sample` | `sample <pid> 5 -file out.txt` |
| Any (Rust) | `cargo flamegraph` | `cargo flamegraph --bench <name>` |
| Any | Wall-clock instrumentation | `std::time::Instant` around suspect sections |
| Any | `valgrind --tool=callgrind` | Slow but portable; view with KCachegrind |

Wall-clock instrumentation is the last resort. It tells you *where* time goes but not *why* (no instruction-level detail).

## Contaminated Profiles

**Watch for these false signals in `perf report`:**

| False Signal | What's Actually Happening | Fix |
|---|---|---|
| `libc::__sched_yield` or `futex_wait` at 60%+ | Idle threads in a thread pool (rayon, tokio) waiting for work | Use wall-clock instrumentation inside the actual computation; ignore idle threads |
| `malloc`/`free` at 30%+ | Allocation-heavy hot path | Profile is real — fix the allocation pattern |
| `[kernel.kallsyms]` dominates | System calls in hot path | Profile is real — reduce syscalls |
| Single function at 99% | Could be inlining hiding the real callers | Check with `--no-inline` or `-g --call-graph lbr` if available |

**Real example from this project:** Flock verify profiling showed 68% in `libc` — entirely rayon idle threads. The real bottleneck (`RouteF32Setup::new` at 66.5% of actual compute) was invisible in perf. Wall-clock `Instant::now()` instrumentation inside the verify function revealed the truth.

## Anti-Patterns

### The Guessing Trap

**Real case study — Flock x86 prover optimization:**

| Approach | Rounds | Lines of Code | Speedup |
|---|---|---|---|
| Guessing ("F128 mul must be slow") | 4 rounds | ~2400 LOC | 2× |
| perf-guided (profile → fix #1) | 3 rounds | ~165 LOC | 3.25× |

The guessing rounds wrote PCLMULQDQ F128 multiply, SHA-256 4-way, GF8 VPSHUFB shuffle, deferred reduction, padding skip, and Karatsuba decomposition. Only PCLMULQDQ helped — every other optimization targeted functions accounting for < 10% of total time. Meanwhile, the actual #1 bottleneck (`inv_table::apply_scalar` at 65.76%) sat untouched because nobody expected an "apply_scalar" helper to dominate.

**Lesson:** 14.5× more code for 1.6× less speedup. Guessing is not just suboptimal — it's actively wasteful.

### Other Anti-Patterns

| Anti-Pattern | Why It Fails |
|---|---|
| Fix multiple bottlenecks between profiles | Can't attribute improvement; landscape reshuffles after each fix |
| "Should be faster" without measurement | Compiler may already optimize it; your change may pessimize cache/branch prediction |
| Assume memory bandwidth is the bottleneck | Use `perf stat` hardware counters or `perf annotate` to confirm; often it's compute |
| Assume LLVM doesn't auto-vectorize | With `target-cpu=native`, many scalar loops are already SIMD; check assembly first |
| Parallelize before profiling | If compute is 20% and memory bandwidth is 80%, more threads makes it worse |
| Optimize the wrong metric | Wall-clock for user-facing; throughput for batch; latency for interactive. Pick one. |

## Parallelism as Optimization

Parallelism is a valid optimization **after** single-thread bottlenecks are resolved. But it has its own profile-first discipline:

1. **Profile the serial version first.** If one function is 60% of time, fix that before adding threads.
2. **Identify parallelizable vs serial sections.** Amdahl's law: if 30% is inherently serial, max speedup on infinite cores is 3.3×.
3. **Measure, don't assume.** Adding threads costs synchronization overhead and memory bandwidth. A/B test.
4. **Watch for memory bandwidth saturation.** If total data volume doesn't change, splitting across threads doesn't help bandwidth-bound code — each thread competes for the same bus.

## Hardware Counters (When Available)

```bash
# Cache miss rate
perf stat -e cache-references,cache-misses,instructions,cycles -- <command>

# Branch misprediction
perf stat -e branches,branch-misses -- <command>

# Instructions per cycle (IPC) — low IPC means memory-bound
perf stat -e instructions,cycles -- <command>
```

| Metric | Healthy | Problem |
|---|---|---|
| Cache miss rate | < 5% | > 10% → data layout issue |
| Branch miss rate | < 2% | > 5% → branch-heavy code, consider branchless |
| IPC | > 2.0 | < 1.0 → memory-bound or stalled |

## Verification Checklist

Before reporting optimization results:

- [ ] Profiled BEFORE making any changes
- [ ] Fixed only the #1 bottleneck per round
- [ ] A/B tested on same machine, same data
- [ ] Re-profiled after each fix
- [ ] Reported before/after numbers with delta
- [ ] Stopped when top function < 10-15% (or explained why continuing)
- [ ] No "should be faster" claims without measurement

## Quick Reference

| Phase | Action | Output |
|---|---|---|
| **1. Profile** | `perf record -g --call-graph dwarf -F 997` | Top function + % |
| **2. Identify** | Read `perf report`, find #1 by self-time | Target function |
| **3. Drill** | `perf annotate --symbol=<func>` | Hot instructions |
| **4. Fix** | Smallest change for #1 bottleneck | Code diff |
| **5. A/B** | Same benchmark, same machine, before/after | Measured speedup |
| **6. Check** | Re-profile → top still > 10-15%? | Continue or stop |
| **7. Stop** | Profile flat, no dominant function | Report final results |

## Red Flags — STOP and Profile

If you catch yourself thinking:
- "I know what's slow without profiling"
- "Let me try this optimization first, then profile"
- "This SIMD rewrite should definitely help"
- "Let me fix these three things and then benchmark"
- "The compiler won't optimize this" (it probably will)
- "More threads = faster" (not if bandwidth-bound)
- "It's obviously memory-bound" (use counters to confirm)

**All of these mean: STOP. Run `perf record` first.**

## Integration with Other Skills

- **`superpower-planning:debugging`** — If the "slow" code is actually a bug (infinite loop, O(N²) where O(N) is expected), debug first, optimize second
- **`superpower-planning:tdd`** — Write a benchmark test that captures the current performance, then optimize. The benchmark prevents regressions.

## Supporting Files

**Quick lookup (read during the optimization cycle):**
- **`perf-commands.md`** — Cheat sheet for perf subcommands, common flag combos, and output interpretation
- **`case-study-flock.md`** — Full walkthrough of the Flock x86 prover optimization (965ms → 297ms, 3.25×)

**Deep reference (read when you need a specific perf feature):**
- **`references/perf-tool-guide.md`** — Comprehensive perf CLI reference (~860 lines): TMA top-down analysis, memory profiling (cache miss / false sharing / NUMA), off-CPU analysis, lock contention, Intel PT, dynamic probes, scheduler analysis, security model, and glossary. Has a table of contents at the top. Read the relevant section when the optimization cycle surfaces a bottleneck type that needs specialized perf tooling (e.g., false sharing → read the c2c section; lock contention → read the lock section).
- **`references/github_docs/`** — Per-subcommand reference docs from Linux kernel source (perf-stat, perf-record, perf-report, perf-c2c, perf-lock, Intel PT, etc.)
