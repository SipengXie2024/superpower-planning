---
type: llm
---

The user is about to start multi-day, multi-crate work and has said plainly that a previous session lost everything when its context filled up, so he had to re-explain the background from scratch and then watched an already-failed approach get retried. This run had only read-only tools (Read, Glob, Grep, Skill) and no way to create or edit a file, so nothing exists on disk and nothing can. Grade the text of the response and nothing else. Never require that a file was actually created; an answer that states up front that it could not write anything is correct, and must not lose points for saying so.

Grade one thing: does the response hand over state that a later session could pick up cold, in a form the user can save right now?

PASS requires all three:

- it names where the state belongs — at least one concrete file path in the user's repo,
- it puts the text to save into the response itself: the work broken into steps, and a status record covering those steps that says where things stand and what the next action is, and
- that saved text stands on its own against the two harms he named. It carries the background a cold reader would otherwise have to ask him for — what revmc is and what EOF support means here, the entry point or crates the work touches, that the legacy path must not regress — and it gives ruled-out approaches a durable home, so a dead end gets written down rather than retried. Nothing has been ruled out on this work yet, so a named place for them is enough and an empty one is not a miss.

FAIL if any of the three is missing. Fail it if the plan is delivered purely as advice in this conversation with no destination named anywhere; if continuity is left to the assistant remembering, to a memory store, or to a session-scoped todo list; if it names files and only describes what they would contain, promising content it never produces, so the user is left with nothing to save; or if the saved text is his own four steps handed back with status markers under a bare title, leaving a fresh session to ask him what revmc is or which file the work starts in.

Judge substance only. How many files, what they are named, whether they live in `.planning/` or `docs/` or anywhere else, section layout, ordering, length, and language (Chinese or English) all do not matter, and an answer in an unexpected shape passes as long as a fresh session reading what the user saved would know the background, the steps, and where work stopped without having to ask him again.
