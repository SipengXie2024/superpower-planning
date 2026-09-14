---
name: wait-what
description: User-invoked repair command for a message that did not land. Use when the user types /wait-what after failing to follow the assistant's last message. The assistant re-pitches what it just said, adds the missing context, writes in the conversation's controlled plain register (ASD-STE100 for English, controlled Chinese otherwise), and swaps invented shorthand for the canonical terms in the repo-root CONTEXT.md.
disable-model-invocation: true
---

Wait — I don't understand where you've got to here. Re-pitch that: give me a little bit of context, and use the ubiquitous language from `CONTEXT.md` (terms keep their original form). Write the conversation's working language in its controlled register — for English, ASD-STE100 Simplified Technical English; for Chinese: one instruction per sentence, active voice, one term per concept, verbs over nominalizations.
