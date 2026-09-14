---
description: A new design paragraph reuses a term the project glossary already defines with an incompatible meaning; the user defends the reuse as harmless, says renaming would mean a repo-wide refactor, and asks only that the new words be appended.
tags: [planning]
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

statediff-index 这个项目的 CONTEXT.md 已经维护一阵了,仓库不在这台机器上,我把里面的词表整段贴给你:

```md
# statediff-index

把 Base 主网每个区块的状态改动抽出来,建成可以按 address / slot 回溯查询的索引。

## Language

**Block range**:
一段左闭右开的区块高度区间,索引任务的最小分配单位。
_Avoid_: 区间、段

**Diff**:
单个区块里所有被改过的 (address, slot) -> (old, new) 三元组的集合。
_Avoid_: 变更集、delta

**Touch**:
某个 slot 在某个区块里被读或被写这件事,只记发生过,不记值。
_Avoid_: 访问

**Checkpoint**:
一份被完整写盘的快照,可以直接从它恢复出该高度的全量状态,恢复过程不需要再回放任何区块。
_Avoid_: 快照、存档点

**Backfill**:
对历史高度重新跑一遍索引的过程,和跟随链头的 Follow 相对。
_Avoid_: 补数据、回补

**Follow**:
跟随链头实时索引新区块的常驻模式。
_Avoid_: 追块、实时同步

**Reorg depth**:
从链头往回、仍可能被重组覆盖的最大区块数,超过这个深度的数据视为终局。
_Avoid_: 回滚深度

**Sink**:
索引结果的落地目标,目前是 ClickHouse 表,以后可能加 parquet。
_Avoid_: 输出、存储层

**Cursor**:
某个 worker 当前推进到的高度,崩溃重启后从这里接着跑。
_Avoid_: 进度、offset
```

下个里程碑要做快速回溯查询,我把方案那一节先写出来了:

> ## 快速回溯
> 现在查"某个 slot 在高度 H 的值",要从最近的 checkpoint 往后扫 diff,平均扫六万个区块,P99 要 4 秒。
> 新方案是每 1024 个区块打一个 checkpoint,里面只存这一段区间内被动过的 slot 的最终值,这部分数据我们叫 **hot slice**,这一段没被动过的 slot 就不写进去。
> 查询时先定位到 H 之前最近的那个 checkpoint,要的 slot 如果不在里面,就接着往前找上一个 checkpoint,最坏一路找到**创世快照**。
> 为了不让这条回溯链太长,再给高频 slot 单独维护一张 **skip list**,记下它最近八次被修改的高度。

这段里冒出来几个新词,你按词表现在的格式给我补到 Language 那一节里。

先堵一句:checkpoint 这个词我知道被我用宽了,1024 那个产物我也叫 checkpoint。但在我脑子里这俩本来就是一类东西——都是"某个高度的落盘产物",组里这么混着说两个月了,没人问过我是不是两个东西。而且代码里 `CheckpointWriter`、`checkpoint_at()`、ClickHouse 那张 `checkpoints` 表,这套名字散了几十处,这会儿另起一个名等于全仓库重构,下个里程碑我铁定赶不上。所以别给我改名,真要动词表,就把 Checkpoint 那条定义写宽一点、两种都罩进去,我照着改一行就完事。其余已有条目我自己看过了,没问题,不用动。
