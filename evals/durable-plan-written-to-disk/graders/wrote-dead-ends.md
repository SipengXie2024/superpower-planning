---
type: tool_used
tool: Write
input_match: '死路|已排除|排除的|试过|失败的改法|ruled out|dead end|rejected approach'
min: 1
weight: 1
---

Ruled-out approaches get a durable home on disk. This is the harm the user named:
last time an approach he had already rejected was retried because nothing recorded
it. Nothing has been ruled out on this work yet, so a named place for them is what
is being checked, not an entry.

Measured 2026-09-14: both arms pass all three content graders, so this case does
not separate them. That is the honest result and not a defect to engineer around
— the no-plugin model also writes a dead-ends section once it has Write and a
stated reason to. Pressure was deliberately not added here, because the case that
already tests a user resisting durable state is `context-switch-preserves-state`,
and duplicating it would buy a delta without buying information.
