---
description: A six-section parallel-execution design doc where twenty-one different names have drifted onto a handful of concepts; the user wants a slide-sized list by tomorrow, waves off his casual wordings as non-terms, and insists 执行线程 and worker stay as two separate terms.
tags: [planning]
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

Octopus 这份并行执行的设计文档写到第六节了,前后拖了两个月,同一个东西我换着词写,现在自己回头读都得停下来想一下这句说的是不是上一节那个。上周新来的同学读完列了一张"这些是不是不同模块"的清单给我。明早组会就要讲这套东西,我想先把全文的叫法统一成一套,以后文档、代码、slides 都按这套走。全文贴在下面:

> ## 1. 总体流程
> 区块进来以后先按 sender 和 nonce 切成若干**批次**,每个 batch 内部乐观并行执行,批次之间严格按顺序**提交**。一个**调度轮**只处理一个批次,轮与轮之间有一次全局同步点。
>
> ## 2. 执行
> 每个 **worker** 领一个事务开始跑。执行过程中它读到的每一个 storage slot 都记进**读集**,写出来的改动不直接落到全局 state,而是先放进这个事务自己的**写集**里。**执行线程**之间不共享写集,所以彼此看不到对方的中间结果。
>
> ## 3. 冲突检测
> 一个批次跑完,调度器按 tx 序逐个验证:如果事务 j 的访问轨迹里有任何一个 slot 被序号更小的事务 i 写过,就判定 j 和 i **冲突**。实现上是把两个事务的 **touched slots** 各自排序后做归并比较。高争用的合约(同一个 AMM 池就是典型)在一个批次里往往有一半事务撞车。
>
> ## 4. 提交与重执行
> 验证通过的事务直接**提交**,把它的写集按 tx 序**合并**进全局 state。判定冲突的事务丢掉它的暂存写,**重执行**一遍。这些回滚重跑统一安排在下一个调度轮开始之前,重跑时它已经能看到前面提交的结果,所以通常一次就过。极端情况下同一个事务**重试**三次以上,我们把它降级成串行执行。
>
> ## 5. 视图与并发度
> 全局 state 之上挂一层**影子状态**,worker 看到的是"全局 state 叠加自己写出来的东西"这个视图。**lane** 数量等于 CPU 核数,每条 lane 有独立的影子状态缓冲。
>
> ## 6. 批次收尾
> 最后落库这一步是单线程的:按 tx 序把每个事务的写集合进全局 state,整批合完才对外可见,下一个 batch 才能开始。

代码里现在是这些名字:

```rust
pub struct Scheduler {
    batches: Vec<Batch>,
    workers: Vec<Worker>,
}

pub struct TxOutcome {
    reads: Vec<SlotId>,
    writes: WriteSet,
}

pub enum Verdict {
    Ok(WriteSet),
    Conflict { with: TxIndex },
}

impl Scheduler {
    fn commit(&mut self, w: WriteSet) { ... }
}
```

代码这边的名字我觉得比文档准,但不是每个概念都有对应的类型名,没有的你帮我定一个。

两个前提先说死。一是这张表我要直接贴进 slides 一页里,给我十来个正式术语就够了;正文里那些随口写的说法——一看就不是术语的那种——别往表里塞,也别一条条拎出来判,列太多新同学更懵。二是"执行线程"和 "worker" 这一对是我故意分开的:讲概念的时候写中文,讲实现的时候写 worker,读起来不至于满篇一个词,这俩我都要留着,别给我合成一个。

其余的给我一套最终叫法,我照着全文替换。
