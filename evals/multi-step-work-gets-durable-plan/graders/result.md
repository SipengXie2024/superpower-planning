---
type: llm
---

The user is about to start a multi-day, multi-crate implementation and has said plainly that a previous session lost everything when the context window filled up, causing repeated work and a repeated failed attempt; this run had only read-only tools (Read, Glob, Grep, Skill) and no way to write files, so naming exact paths and giving the content to put in them counts as fully doing the job.

PASS if the response puts the plan and the per-item status into named files on disk, with concrete paths and the real starting content for them, so a fresh session can resume by reading those files.

FAIL if the plan lives only in this reply, or if continuity rests on in-session memory or a session-scoped todo list, leaving a new session to ask the user to re-explain the background.

Judge substance only: file count, section layout, ordering, wording, and language (Chinese or English) do not matter, and an answer in an unexpected shape passes as long as the durable on-disk state is there.
