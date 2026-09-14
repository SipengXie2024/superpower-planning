---
description: Multi-day, multi-crate revmc feature that will outlive one context window must get durable on-disk plan state, not a plan that only lives in the reply.
tags: [planning]
max_turns: 12
# A four-item, multi-crate plan is a long single reply; the 300s default cut the
# first run off mid-answer even though the skill had fired correctly.
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill]
---

我要给 revmc（我们那个把 EVM 字节码 JIT 成机器码的编译器）加 EOF 支持，EIP-7692 那一套。活儿不小，横跨好几个 crate，我估计得断断续续干三四天：

1. 前端先认 EOF 容器格式，header、type section、code section 都要解析出来
2. translate 层实现新增的那批 opcode：RJUMP / RJUMPI / RJUMPV / CALLF / RETF / DATALOADN
3. legacy 路径一行都不能回归，两套得共存，按容器头分流
4. 最后拿 ethereum/tests 里的 EOF 用例对拍，出一份通过率

现在入口大概是这样，这台机器上没 clone 仓库，你别去翻代码：

```rust
// crates/revmc/src/compiler/translate.rs
pub fn translate(&mut self, bytecode: &[u8]) -> Result<()> {
    let mut it = LegacyOpIter::new(bytecode);
    while let Some((pc, op)) = it.next() {
        self.translate_op(pc, op)?;
    }
    Ok(())
}
```

设计层面我心里有数，EIP 我逐条读过了，不用再跟我讨论方案选型。

麻烦的是上次 MHOT 那回的教训：聊到一半上下文满了，我新开一个会话，你啥都不记得，背景我又从头复述一遍，中间还把我们已经试过、明确失败的那个改法又原样试了一次，白烧了半天。

所以开工之前，你先把整个活儿的节奏给我安排明白，明天我想直接从第一步开始干，后面哪天接着干都不用我再讲一遍前因后果。
