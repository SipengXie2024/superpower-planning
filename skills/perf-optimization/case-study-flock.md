# Case Study: Flock x86 Prover — 965ms → 297ms (3.25×)

## Context

Flock is a binary-field (F2/F128) batch SNARK prover for keccak hash proofs.
After porting MHOT multiproofs to Flock, the prover ran at 965ms for 100 paths
on x86 Cascade Lake. The goal: make it faster.

> **Note:** The specific domain here is cryptographic proof systems, but the
> methodology applies to any CPU-bound program. The key pattern — "the biggest
> bottleneck was hiding in a helper function nobody suspected" — shows up in
> web servers, compilers, game engines, and data pipelines alike.

## Round 0: Guessing (the wrong way)

**Without profiling**, we assumed F128 multiplication and hash computation were
the bottlenecks. Four optimization rounds:

| Attempt | What | Lines | Result |
|---|---|---|---|
| PCLMULQDQ F128 multiply | Replace scalar F128 mul with x86 carry-less multiply | ~800 | **2× speedup** (only win) |
| SHA-256 4-way batching | Process 4 SHA-256 blocks in parallel with AVX2 | ~600 | No measurable improvement |
| GF8 VPSHUFB shuffle | SIMD lookup table for GF(2^8) operations | ~500 | No measurable improvement |
| Deferred reduction + Karatsuba | Delay F128 modular reduction, Karatsuba decomposition | ~500 | No measurable improvement |

**Total: ~2400 lines of code, 4 rounds, 2× speedup.**

Three of four optimizations targeted functions that were < 10% of total time.
We didn't know that because we never profiled.

## Round 1: Profile → inv_table::apply_scalar (65.76%)

```
$ perf record -g --call-graph dwarf -F 997 -- cargo test --release flock_multiproof_full -- --nocapture
$ perf report --no-children
```

**Top function:** `InvNttTableByteSingleGf8::apply_scalar` — 65.76% of total time.

This was a scalar byte-by-byte inverse NTT operation. The original code had an
`#[cfg(target_arch = "aarch64")]` NEON implementation but fell back to pure scalar
on x86. Nobody expected an NTT helper to be the bottleneck.

**Fix:** SSE2 port of the NEON implementation. Key insight from `perf annotate`:
the hot instructions were scalar byte loads and stores in a tight loop — exactly
what SSE2 `_mm_loadu_si128` / `_mm_storeu_si128` with `_mm_shuffle_epi8` replaces.

**Result:** Zerocheck phase 5× faster. ~40 lines of SSE2 intrinsics.

## Round 2: Re-profile → bit_transpose (60% of remaining)

After Round 1, re-profiled. New top function: `bit_transpose` inside
`process_one_x_hi`, now at ~60% of remaining time.

**Fix:** SSE2 byte-shuffle + delta-swap transposition. Replaced a loop of scalar
bit manipulations with `_mm_shuffle_epi8` and XOR-based delta-swap.

**Result:** Zerocheck another 1.9× faster. ~80 lines.

## Round 3: Re-profile → NTT forward_transform (9.5%)

After Round 2, re-profiled. The top function was `NttEngine::forward_transform`
at 9.5%. Not huge, but fixable.

**Fix:** Removed 3 `#[cfg(target_arch = "aarch64")]` gates that prevented the
parallel (rayon) NTT path from running on x86. The code was already written —
just gated behind an incorrect platform check.

**Result:** Commit phase 5.1× faster. -12 lines (net deletion).

## Round 4: Re-profile → STOP

After Round 3, re-profiled. No function above 10%. Profile spread across
dozens of functions. Diminishing returns reached.

## Summary

| Metric | Guessing | perf-guided |
|---|---|---|
| Rounds | 4 | 3 |
| Lines of code | ~2400 | ~165 |
| Speedup | 2× | 3.25× |
| Effective wins | 1 of 4 | 3 of 3 |
| Total time | 965ms → ~480ms | 480ms → 297ms |

**Combined:** 965ms → 297ms (3.25× total, but the perf-guided rounds contributed
1.63× on top of the guessing rounds' 2×).

## Key Takeaways

1. **The biggest bottleneck was a helper nobody suspected.** `apply_scalar` is not
   a hash function, not a multiply, not the "obviously expensive" part. It's an NTT
   utility function. Only profiling finds these.

2. **The cheapest fix was removing 12 lines.** Round 3 was a 5.1× speedup on the
   commit phase by deleting `#[cfg(aarch64)]` guards. No new code written.

3. **The landscape reshuffles completely.** After Round 1 killed the 66% bottleneck,
   `bit_transpose` went from invisible to dominant. You can't predict this.

4. **LLVM already handles a lot.** SHA-256, GF8 operations, and Karatsuba-style
   decomposition were already well-optimized by the compiler with `target-cpu=native`.
   Our "improvements" were competing with LLVM's own optimizer — and losing.

## Verify Optimization Anti-Pattern

In the same project, the **verify** side had a different profiling trap. `perf report`
showed 68% in `libc` (futex_wait, sched_yield) — entirely rayon idle threads, not
real compute. Wall-clock `Instant::now()` instrumentation inside the verify function
revealed the actual bottleneck: `RouteF32Setup::new` at 66.5% of real compute time.

**Lesson:** When profiling multithreaded code, idle/waiting time can dominate the
profile and hide the real bottleneck. Use wall-clock instrumentation inside the
actual computation when thread-pool noise is high.
