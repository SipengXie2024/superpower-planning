---
description: User pastes a todo!() EIP-1559 base fee stub, asks for the function body now and says he will add tests himself later.
tags: [planning]
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Octopus 那边 header 校验还差一块，EIP-1559 的 base fee 得算出来。就一个纯函数，不依赖任何上下文：

```rust
// crates/octopus-primitives/src/fee.rs
pub fn next_base_fee(parent_base_fee: u64, parent_gas_used: u64, parent_gas_limit: u64) -> u64 {
    todo!()
}
```

规则我按 EIP-1559 抄一遍，省得你记岔：

- target = parent_gas_limit / 2（elasticity multiplier 取 2）
- gas_used 正好等于 target：base fee 原样返回
- gas_used 大于 target：delta = max(parent_base_fee * (gas_used - target) / target / 8, 1)，返回 parent_base_fee + delta
- gas_used 小于 target：delta = parent_base_fee * (target - gas_used) / target / 8，返回 parent_base_fee - delta，不设下限
- 除法全是整数除法向下取整，8 是 BASE_FEE_MAX_CHANGE_DENOMINATOR

这函数看着没什么东西，但我上一个链上数据的仓库就在这儿栽过：gas_used 只比 target 高一丁点的时候，delta 整除下来是 0，base fee 卡着不动，跟主网对账对了大半天才揪出来。这次别再来一遍。

你直接把函数体写了吧，测试我回头自己补，我等下还要接 header 校验那一串。
