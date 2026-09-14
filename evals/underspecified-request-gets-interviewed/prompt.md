---
description: User pastes a vague contract-hotness export spec and asks to have its holes found and questioned before he implements it next week.
tags: [planning]
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

上周顺手写了一版 spec，本来想直接照着实现，回头看觉得糙得不行。全文就这么点东西：

```markdown
# 合约热度导出（hotness export）

## 背景
MHOT 要做分层执行：热的合约提前交给 revmc 编成 native code，冷的继续走解释器。
现在决策没有依据，先离线跑一份热度数据出来。

## 需求
- 扫一段区块区间，统计每个合约被调用了多少次
- 结果写成 parquet，下游分析脚本直接读
- 要能跑全量主网历史

## 接口
pub fn export_hotness(from: BlockNumber, to: BlockNumber, out: &Path) -> Result<()>

## 验收
跑完不崩，parquet 能用 pandas 打开
```

补两句环境：执行器是我们自己那套 revm fork，每笔交易的完整执行轨迹都拿得到；archive 节点的数据在本机，磁盘管够。

我下周想直接照着这份 spec 开工，所以这会儿先别写代码。你把它整个过一遍，哪儿没写明白、哪儿是我想当然了，你就直接问我，我一条条答你，最后咱们把它补成一份能交出去的 spec。
