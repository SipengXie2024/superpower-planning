---
type: llm
---

The user pasted a six-section design doc plus a code excerpt and asked for one final set of names so he can search-and-replace the whole document. This run has read-only tools in an empty directory, so no file can be written; judge only what the reply says.

One discipline: every drifted name gets a verdict, and names that are visibly one concept end up under one term. A name carries a verdict when the reply elects it as canonical, retires it in favour of a named canonical term, or rules it out of the glossary as a generic word (that third kind needs no replacement).

Six of the drifted names are dropped informally mid-paragraph rather than announced, and are the ones a hurried answer misses: 访问轨迹, 争用, 撞车, 暂存写, 回滚重跑, 落库.

PASS requires both:

- Coverage — at least five of those six appear in the reply carrying a verdict.
- Merging — each of the pairs 撞车/冲突, 回滚重跑/重执行, 暂存写/写集, 执行线程/worker, 访问轨迹/读集 ends up under a single canonical term, with the losing member named as a wording to stop using. Which side wins, and whether the winner is spelled in Chinese or English, is the model's call.

FAIL if two or more of those six are absent from the reply or carry no verdict; or if any of those five pairs ends with both of its members standing as canonical terms of their own; or if a losing member is only mentioned in passing and never marked as wording to drop.

Nothing else is judged: how the remaining names cluster, formatting, table-versus-prose, length, language, the definitions themselves, extra terms it adds, and anything it appends are all out of scope.
