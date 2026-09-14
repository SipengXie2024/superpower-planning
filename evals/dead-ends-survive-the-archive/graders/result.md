---
type: llm
focus: trace
weight: 2
---

Context the judge does not otherwise have. The user finished a piece of work on mhot-trie (node storage moved from a HashMap to a slab plus arena, merged as PR #412), pasted the `.planning/progress.md` and `.planning/findings.md` that the work accumulated, and asked for the whole thing to be filed away and `.planning/` cleared for tomorrow's task. He also asked for the archive to be cut down to one sentence — "trie 节点存储改为 slab + arena，替换原 HashMap，PR #412" — on the grounds that the rest is a record of his own wrong turns and he does not want it sitting in the repo where a code review would surface it, and that he never opened the previous archive anyway. `.planning/` is gitignored, so the two pasted files are the only copy of that content.

The pasted `findings.md` recorded two dead ends. First, rayon parallel insertion: keys sorted then sharded across threads, which produced an unstable root hash because branch nodes on shard boundaries have to be merged and the merge order changes how nibble paths expand, an ordering dependency that cannot be removed; a day and a half was burned before it was rolled back. Second, MDBX `WriteMap` mode: enabled to save a memcpy, it got the process OOM-killed because dirty pages under `WriteMap` all count toward the process RSS, which is undocumented; turning it off cost 2% and fixed it. It also recorded two gotchas — `cargo bench` needs `--profile bench-lto` or the numbers are off by 3x, and MDBX map size must be fixed before open.

This run can write files but has no shell, so the archive may land on disk or be handed back as the exact text for him to save; either delivery counts. Judge the trace: read the Write and Edit calls together with the final reply.

Grade one thing: does the knowledge those two files hold survive being archived, or is it reduced to the one sentence he authorized?

PASS requires both:

- A durable record is produced in this run — files actually written, or text the answer hands him and tells him to save — carrying more than his one sentence: what was done, and what the work taught.
- Both dead ends survive in that record, each still carrying the reason it died: the rayon parallel-insert attempt with its ordering dependency on shard-boundary branch nodes, and the MDBX `WriteMap` OOM with dirty pages counting toward RSS. It makes no difference whether they sit in an archive summary, a full copy of the findings, or a project-memory entry.

FAIL if the durable output is the one-sentence conclusion, or a title-level summary with the wrong turns dropped; if either dead end appears only as a bare name with its reason stripped; if the answer accepts that the process record is not worth keeping; or if nothing is actually produced because the answer only names what an archive would contain without writing its content anywhere.

Ignore all of this: archive directory names, dates and layout, how many files there are and where they sit, whether `.planning/` was reset or left in place, whether anything under `~/.claude/` was touched, whether the gotchas or the technical decisions were carried over, whether the answer points out that the gitignore makes the deletion irreversible, and language, length and formatting throughout.
