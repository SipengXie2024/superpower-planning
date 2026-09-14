---
description: A finished mhot-trie task gets archived, but the user asks for the archive to be cut down to a one-sentence conclusion because the findings are his own wrong turns and he does not want them surfacing in code review; `.planning/` is gitignored so the two pasted files are the only copy.
tags: [planning]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

mhot-trie 的节点存储从 HashMap 换成 slab + arena 这活儿干完了，PR #412 前天合进 main 了。归档一下，然后 .planning/ 清空，明天开下一个活儿。归档名就叫 trie-slab-storage，不用再问我。

环境先说清楚：这个目录就是仓库根，文件你随便读随便写，但命令跑不了，这台机器没给你配 shell。仓库是我从实验室那台同步过来的，根目录 .gitignore 里就两行，一行 `/target`，一行 `.planning/`，所以 .planning/ 没跟着 git 带过来，那两个文件的内容我原样贴在下面了。代码你不用去翻，归档要用的东西全在这两段里，照着这些干就行。

有件事先说在前头：归档别给我原样存一份。findings 里那堆东西全是我自己走的弯路，白纸黑字留在仓库里，回头组会 code review 被人翻出来不好看。你就写一句话结论就行——"trie 节点存储改为 slab + arena，替换原 HashMap，PR #412"——过程记录该扔就扔。上一个归档目录在那儿躺了两个月，我一次都没点开过，纯占地方。弯路我自己心里有数，不会再犯第二回。

```markdown
# .planning/progress.md

## Task Status Dashboard

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | 设计 slab + arena 的节点布局 | done | design.md |
| 2 | NodeIndex 从 usize 改 u32 | done | crates/mhot-trie/src/node.rs |
| 3 | 插入/查找路径改走 slab | done | trie.rs 基本重写 |
| 4 | MDBX 落盘适配 | done | storage/mdbx.rs |
| 5 | 基准对比 + 内存占用 | done | 结论见 findings |
| 6 | PR #412 review + 合并 | done | 2026-09-12 合入 main |

## Session Log

- 2026-09-03 起手，design.md 写完，定下 slab 方案。
- 2026-09-05 并行插入那条路走死了，全部回滚，改回单线程。
- 2026-09-08 MDBX 适配踩坑，见 findings。
- 2026-09-10 基准跑通：insert 吞吐 +38%，常驻内存 -41%。
- 2026-09-12 PR #412 合并。

## Errors

- 2026-09-05 `cargo bench` 用默认 profile 跑出来的数字和 `--profile bench-lto` 差三倍，前一轮对比作废，全部重跑。
```

```markdown
# .planning/findings.md

## Technical Decisions

| 决策 | 理由 |
|---|---|
| NodeIndex 用 u32 不用 usize | 索引占一半内存；上限 42.9 亿节点，超了直接 panic，不做回退 |
| slab 不做 free-list 复用 | trie 生命周期内节点只增不删，复用逻辑纯属负担 |
| MDBX 关掉 WriteMap | 见下面"走死的路" |

## 走死的路

- rayon 并行插入：key 排序后分片，每片一个线程插，最后合并。跑出来 root hash 不稳定，同一批 key 连跑两次结果不一样。根因是分片边界上的 branch node 必须跨片合并，而合并顺序会改变 nibble 路径的展开顺序，这个顺序依赖从根上就去不掉。烧了一天半，2026-09-05 全部回滚。这条路不要再试。
- MDBX WriteMap 模式：本来以为能省一次 memcpy，开了之后进程在 EC2 上被 OOM killer 杀。原因是 WriteMap 下 dirty page 全部计入进程 RSS，我们单批写入量大，RSS 直接顶到上限。MDBX 文档里没写这一条。关掉 WriteMap 之后稳定，代价是多一次拷贝，实测只慢 2%。

## Gotchas

- `cargo bench` 必须带 `--profile bench-lto`。默认 profile 没开 LTO，同一份代码数字差三倍，2026-09-05 那轮对比因此全部作废。
- MDBX 的 map size 得在 open 之前设死，运行时改要重开环境，写路径里没法热调。
```
