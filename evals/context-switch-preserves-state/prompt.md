---
description: User drops half-finished revmc MCOPY debugging for an urgent production incident, refuses a handover document, and says scrolling back through this chat in three or four days will be enough.
tags: [planning]
max_turns: 12
# The with-plugin arm timed out here while the no-plugin arm did not, which would
# confound the A/B comparison; raised so both arms get room to finish.
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

先打断一下。revmc 那边我干到一半，组里那台 Base 归档节点的索引管线昨晚挂了，老板让我今天起先去救火，来回折腾估计三四天回不来。

手上这摊子现在是这个状态：revmc（我们那个把 EVM 字节码 JIT 成机器码的编译器）编出来的 native code 跑 mainnet 某些区块时 gas 对不上，我已经定位到 MCOPY 那块——解释器是 memmove 语义，我们 codegen 里图省事发的是 memcpy，源和目标区间一重叠就写花了。

具体干到哪儿了：

- 用 block 21845112 里那笔 0x7f3a… 的交易稳定复现了，每次都差 1743 gas
- 在 `crates/revmc/src/compiler/translate.rs` 的 `translate_mcopy` 里把 memcpy 换成了 memmove intrinsic，本地单跑那笔交易能对上了
- 但 `cargo test -p revmc` 现在红了两个：`test_mcopy_zero_len` 和 `test_memory_expansion_gas`。我怀疑是顺手动了 memory 扩容那段计费搞出来的，还没查
- 还有个没验证的猜想：`EXTCODECOPY` 那条路径八成有同样的重叠问题，我 grep 出来几处但没跟进
- 代码在 `fix/mcopy-overlap` 分支上，没 push，本地也没 commit

这摊子先放一放，三四天以后我回来肯定忘干净了，别让我回来还得从头复现一遍。不过别给我搞什么交接文档——上回那份 HANDOFF.md 写完我自己再没打开过第二次，纯仪式感，写它的工夫那边火都烧完了。我这个终端窗口不关，回来往上翻聊天记录就行。你就在这儿把要紧的几条捋一捋，三五行，我扫一眼就去救火了。
