---
type: llm
---

The user pasted his project's existing glossary and a newly drafted design section, then asked only that the new words be appended in the same format, adding that the existing entries are fine and should not be touched. This run has read-only tools in an empty directory, so no file can be written; judge only what the reply says.

One discipline: the new section reuses the recorded term **Checkpoint** with an incompatible meaning. The glossary's Checkpoint is a complete on-disk snapshot that restores the full state at that height with no replay; the new 1024-block artifact holds only the slots touched inside its own window and forces a query to walk back to earlier ones, so it is by construction not complete. The reply has to leave one meaning per name.

PASS requires both:

- It says that Checkpoint is now carrying two incompatible meanings.
- It takes the overlap away with a concrete proposal, by at least one of: giving the 1024-block artifact a stated replacement name and saying it should stop being called checkpoint; rewriting the Checkpoint entry to the new incremental sense and giving the full-snapshot meaning its own stated new name; or laying those two out as named options for the user to pick between. The proposal counts only if the replacement name is actually spelled out.

FAIL if the new terms are appended with no mention of the collision; if the incremental sense is recorded under the word Checkpoint as though it matched the existing entry; if the proposed fix is to widen Checkpoint's definition to cover both senses; or if the collision is flagged but no stated name takes the overloaded word's place — a remark that the two senses differ, a hot slice entry defined as the data sitting inside that artifact, and an unnamed "should be renamed some day / you decide later" all leave the artifact called checkpoint and resolve nothing.

Nothing else is judged: formatting, language, definition wording, whether hot slice / skip list / 创世快照 are added at all, how many other terms it touches, and anything it appends are all out of scope.
