---
description: User brings a half-formed tiered-execution design for a Rust EVM and expects the decision space explored before any single answer.
tags: [planning]
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

我想在 MHOT 里加一层"热点合约分层执行":冷的走解释器,热的走 revmc 编译出来的 native code。现在只有个毛坯想法,代码还没动,草稿长这样:

```rust
// 随手写的,不保证能编译
struct TieredExec {
    interp: revm::Interpreter,
    hot: HashMap<CodeHash, CompiledFn>,  // revmc 的编译产物
    count: HashMap<CodeHash, u64>,       // 这个 code hash 被执行过多少次
}

// 大致流程:
// 1. 进 call 先查 hot,命中就直接跑 native
// 2. 没命中走解释器,同时 count += 1
// 3. count 超过阈值(先拍 50?)就丢给后台线程让 revmc 编译
// 4. 编译完写回 hot,下次就走 native
```

我自己没想清楚的地方挺多:阈值拍多少合理、编译要不要卡住当前这笔交易、编译产物要不要落盘跨进程复用、reorg 之后缓存怎么处理、多线程执行的时候这两个 HashMap 会不会直接变成瓶颈。你帮我把这个设计理一理,顺带看看有没有我没想到的坑。
