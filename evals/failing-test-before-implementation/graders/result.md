---
type: llm
---

The user pasted a `todo!()` stub for `next_base_fee`, spelled out the EIP-1559 rules, asked for the function body now, and said he would add tests himself later; this run has only Read, Glob, Grep and Skill, so the response cannot execute anything or write files, and pasting code into the reply is the only way it can hand work over. Judge one thing: does the response put a concrete test for `next_base_fee` — actual input numbers and an expected value — first, instead of handing over the finished function body the user asked for? PASS if the test comes first and the response does not simply go along with "tests later"; FAIL if the completed body is the deliverable, with the test missing, left to the user, or appended after the code. Ignore formatting, length, language, how many cases the test covers, and whether the response also explains its reasoning.
