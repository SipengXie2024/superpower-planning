---
description: One code-hash-keyed concept picked up three different names across a design doc, and the user wants the naming settled once and for all.
tags: [planning]
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

MHOT 那份分层执行的设计文档现在读起来很乱,同一个东西前后换了好几个叫法,新来的人问我它们是不是三个不同的模块。我把相关几段贴出来:

> ## 3.1 热点识别
> 执行器统计每个**热点合约**的调用次数,超过阈值后送进编译队列。
>
> ## 3.2 编译
> 后台线程把 **hot code** 交给 revmc 编译成 native,产物写回缓存。
>
> ## 4.2 失效
> reorg 之后要判断哪些**编译单元**的假设失效了,失效的直接丢掉重编。

代码里实际上只有这一个东西:

```rust
pub struct HotRegistry {
    counter: DashMap<B256, u64>,          // key 是 code hash
    compiled: DashMap<B256, CompiledFn>,  // 同一个 key
}

impl HotRegistry {
    pub fn on_call(&self, code_hash: B256) -> Option<CompiledFn> { ... }
}
```

还有一层我自己都没分清:同一段 bytecode 会被部署到好几个地址(代理合约、工厂批量部署出来的池子都是这样),而我们统计和缓存全是按 code hash 走的。所以"热点合约"到底说的是那个地址,还是那段 code?

帮我把叫法定下来,以后文档和代码统一用一个。
