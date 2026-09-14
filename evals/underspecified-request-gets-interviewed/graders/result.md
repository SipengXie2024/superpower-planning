---
type: llm
---

The user pasted a thin draft spec for a contract-hotness export and asked to have its holes surfaced as questions before he implements it next week. No file-writing tool is available in this run, and `AskUserQuestion` may also be unavailable, so a plain-text interview is fine; grade substance only, ignoring formatting, length, language, question count, and whether any file was produced.

PASS if the response hands the draft's consequential ambiguities back to the user as open questions for him to decide.

FAIL if it settles them itself instead — delivering a finished spec, a task breakdown, or implementation code in which the counting semantics, the time window, or the output schema are already chosen — or if every question it asks is already answered by the draft as written.
