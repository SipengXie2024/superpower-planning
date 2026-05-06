---
name: dual-review
description: Run `simplify` (reuse/quality/efficiency lens) and Codex (external second opinion via collaborating-with-codex) in parallel to review recent code changes, consolidate both reports, then block on explicit user approval before any edits. Use whenever the user asks for "dual review", "simplify + codex review", "double check", "review before commit", wants two independent perspectives on a change, or asks to review code with both internal heuristics and an external model. Especially useful before risky merges, refactors, or when the user distrusts a single reviewer's judgment.
---

# Dual Review (simplify + codex)

Get two independent reads on the same changes — `simplify` (reuse, quality, efficiency) and Codex (external correctness / design second opinion) — **in parallel**, consolidate findings, then block on explicit user approval before any file is touched.

**Announce at start:** "I'm using dual-review: I'll run simplify and Codex in parallel (review-only), consolidate findings, and block on your approval before any edits."

## Why this exists

A single reviewer has blind spots. Internal heuristics (`simplify`) are good at reuse, dead code, and efficiency, but tend to miss subtle correctness issues. External models (Codex) are good at fresh-eyes bug hunting and design critique, but don't know codebase conventions. Running both in parallel and gating on human approval prevents the common failure modes of "lone reviewer misses something" and "reviewer's fix gets auto-applied without the human seeing what changed".

## Non-negotiables

The rules below are non-negotiable because violating any of them defeats the skill's purpose — either you lose the parallel-review benefit, lose the blocking approval gate, or risk silently modifying code.

- **Parallel dispatch, single message.** Launch both reviewers in one message (Agent call for simplify + Bash background call for Codex). Serializing them wastes time and can bias the second review by letting the first's report leak in.
- **Review-only mode.** Neither reviewer writes code. They return findings only. If the reviewer's own instructions say it can edit (e.g. `code-simplifier` agent), override explicitly in the prompt.
- **Approval gate is mandatory.** After both reports return, use `AskUserQuestion` to ask which fixes to apply. An implicit "sounds good" from surrounding conversation does not count — ask the question.
- **Fixes run in a fresh subagent.** After approval, dispatch a new implementer subagent with the consolidated fix list. This isolates context and prevents the reviewer's reasoning from contaminating the implementation.
- **Scope is always confirmed.** Before dispatching, ask the user what to review. Do not default to "recently changed files" or "last commit" silently.

## Procedure

### 1. Confirm scope

Ask the user what to review. Use `AskUserQuestion` with options such as:

- Uncommitted changes (`git diff HEAD`)
- Last N commits (prompt for N)
- A specific commit or range
- Specific file paths (user supplies)

Capture the scope as a concrete list of file paths and/or a git revision range. The same scope is passed to both reviewers verbatim — if one ends up reviewing different code, the consolidation step becomes meaningless.

### 2. Parallel dispatch

In ONE message, launch both tools. The reviewer prompts must be self-contained because subagents and Codex have no conversation history.

**Simplify reviewer** via Agent tool:

```
Agent({
  description: "Simplify review (read-only)",
  subagent_type: "code-simplifier:code-simplifier",
  prompt: """
REVIEW-ONLY MODE. Do NOT edit, write, or commit any files. Return findings only.

Scope to review:
<list of file paths or git range, verbatim from step 1>

Task: apply the simplify lens — reuse opportunities (can this use an existing function?), quality issues (naming, dead code, over-abstraction, under-abstraction), efficiency problems (unnecessary work, better data structures).

Output format:
- Issues grouped as Critical / Important / Minor
- Each entry: `<file>:<line>` → what to change → why
- If there is nothing to flag, say "No issues" plainly

Under 500 words. Do not speculate beyond the scope.
"""
})
```

If `code-simplifier:code-simplifier` is unavailable in the current environment, fall back to `general-purpose` with a fuller prompt that emulates the simplify lens explicitly. Verify availability before dispatch:

```
# Before dispatching, check the available subagent list shown in the system reminder.
# If "code-simplifier:code-simplifier" is not present, use this fallback prompt:

Agent({
  description: "Simplify-style review (read-only, fallback)",
  subagent_type: "general-purpose",
  prompt: """
REVIEW-ONLY MODE. Do NOT edit, write, or commit any files. Return findings only.

Apply the `simplify` skill's lens — read the scope and report:
1. **Reuse**: Can this use an existing function / module / utility already in the codebase? Cite the existing one with `file:line`.
2. **Quality**: Naming consistency, dead code, over-abstraction (premature interface for a single caller), under-abstraction (3+ near-duplicate blocks), missing error handling at boundaries, comments that explain WHAT instead of WHY.
3. **Efficiency**: Unnecessary work (repeated computation, redundant allocations), better data-structure choices, hot loops doing O(n²) where O(n) suffices.

Scope to review:
<list of file paths or git range, verbatim from step 1>

Output:
- Issues grouped Critical / Important / Minor.
- Each entry: `<file>:<line>` → what to change → why.
- "No issues" if nothing to flag.

Under 500 words. Stay in scope.
"""
})
```

This fallback should produce findings comparable to the dedicated agent. Note in the consolidated report which reviewer was used so the user knows the lens was emulated.

**Codex reviewer** via Bash, background, via `superpower-planning:collaborating-with-codex`. Resolve `${CLAUDE_PLUGIN_ROOT}` to an absolute path (`PLUGIN_ROOT="$(realpath "${CLAUDE_PLUGIN_ROOT}")"`) and substitute it into the command — the Bash tool does not expand it for you.

```
Bash({
  command: """
python3 "${PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py" \\
  --cd "<absolute project root>" \\
  --sandbox read-only \\
  --PROMPT "REVIEW-ONLY. Do not propose a patch — return findings only.

Scope to review:
<same list / range as simplify>

Focus: correctness bugs, edge cases, design issues, thread-safety, error handling. Do not duplicate obvious lint / style issues — another reviewer handles that lens.

Output format:
- Issues grouped as Critical / Important / Minor
- Each entry: file:line + what + why
- If nothing to flag, say 'No issues'

Under 400 words."
""",
  run_in_background: true,
  description: "Codex review (read-only)"
})
```

`run_in_background: true` is required — Codex blocks for 60-120s and running it foreground freezes the conversation. See `collaborating-with-codex` skill for details.

### 3. Wait for both, then collect

Simplify returns synchronously in the agent tool result. Codex returns via a task completion notification — when it arrives, Read the output file and extract `agent_messages` from the JSON.

If either reviewer fails, surface the failure to the user and ask whether to retry, proceed with the single successful reviewer, or abort. Do not silently drop a failed reviewer — the user should know the review is half-complete.

Specific failure modes to handle (each with a user-facing message, not a silent retry):

- **Codex bridge timeout** (>120s without response from `codex_bridge.py`) — show "Codex did not respond within 120s. The simplify reviewer returned: [summary]. Retry Codex, proceed with simplify only, or abort?"
- **Codex sandbox rejection** (e.g. the bridge returned "sandbox blocked Read on /path") — note that Codex may not have the same file access as the main session. Tell the user which paths Codex could not read and ask whether to (a) re-dispatch with `--sandbox workspace-write` (only if the user explicitly confirms — that escalates Codex's permissions), (b) run only simplify, or (c) provide the missing files inline in the Codex prompt.
- **Codex non-zero exit with stderr** — surface the stderr verbatim. Do NOT swallow it.
- **Empty Codex output** (process exited 0 but `agent_messages` was empty) — usually means Codex declined to engage, often due to prompt phrasing or sandbox confusion. Show a one-line note and ask whether to rephrase or skip.
- **Simplify subagent timeout / unavailable** — the in-session Agent dispatch should respond in seconds; if it errors with "subagent_type not found" or similar, fall back to the `general-purpose` template from Step 2.
- **Both succeed but produce contradictory scope coverage** (one reviewed the wrong files) — discard the off-scope review's findings and ask the user whether to re-dispatch the off-scope reviewer.

Do not proceed to consolidation until both are in (or the user has chosen how to handle a failure).

### 4. Consolidate

Produce one merged summary for the user. Prefer the following structure because it highlights agreement (strong signal) and disagreement (needs human judgment):

- **Both flagged:** issues both reviewers independently raised → highest confidence
- **Simplify only:** reuse / quality / efficiency items
- **Codex only:** correctness / design items Codex caught
- **Conflicts:** places where the two reviewers suggest incompatible changes → flag explicitly, describe both sides

Keep the merged summary tight. Link to the full raw reports only if the user asks. A bloated summary hides the signal.

### 5. Approval gate

Call `AskUserQuestion` with the consolidated findings. A reasonable default option set:

```
AskUserQuestion({
  questions: [{
    question: "Dual review complete. Which fixes to apply?",
    header: "Apply fixes",
    options: [
      { label: "Critical + Important",
        description: "Apply everything both reviewers ranked above Minor." },
      { label: "Agreement items only",
        description: "Apply only items both reviewers independently flagged." },
      { label: "Let me pick",
        description: "List individual items and I'll approve each." },
      { label: "No changes",
        description: "Keep code as-is; discard the review." }
    ],
    multiSelect: false
  }]
})
```

Adjust the options to match what actually exists in the merged report — if there are no "agreement" items, drop that option. Do not present options that nothing maps to.

**If "Let me pick":** enumerate each item with a short label and a yes/no per item using a follow-up `AskUserQuestion` (or several if the list is long).

### 6. Apply via fresh subagent

After approval, dispatch a NEW implementer subagent with the approved fix list. Do not apply edits from the main conversation — the review discussion has polluted the main context and the implementer benefits from a clean start.

```
Agent({
  description: "Apply approved dual-review fixes",
  subagent_type: "general-purpose",
  prompt: """
Apply exactly these fixes. Each item is a concrete `file:line` + change + rationale from a prior review. Do not add fixes beyond the list, do not broaden scope.

<paste approved fix list verbatim>

After editing:
- Run the project's check command (e.g. `cargo check`, `npm run build`, etc. — infer from the repo)
- Run relevant tests for the touched files
- If a fix breaks something, stop and report back — do NOT commit a broken state

Do not run `git commit` unless explicitly instructed in the fix list.
"""
})
```

### 7. Report back

After the implementer returns, summarize what was applied (commits if any, tests run, failures encountered). The user should finish the turn knowing exactly what changed and what did not.

## When NOT to use

Using this for trivial cases wastes time and conditions the user to ignore the approval gate, which erodes the skill's value.

- Single-file trivial change (typo, rename, one-line fix) — overkill.
- Pre-implementation (nothing has been written yet) — use `brainstorming` or `writing-plans` instead.
- User has already decided what to change and is asking for execution — dispatch directly, skip the review.
- Critical hot-fix under time pressure where the user explicitly wants to move fast — offer a single reviewer or skip review, surfacing the tradeoff.

## Red flags

These mistakes show up repeatedly and each one silently breaks the skill's contract. Watch for them:

- Applying any fix before Step 5 approval lands → forbidden. If an earlier step "clearly needs" a fix, note it in the report, do not edit.
- Running Codex in the foreground → freezes the conversation. Always `run_in_background: true`.
- Proceeding with only one reviewer because the other is slow → wait for both, or explicitly surface the failure and let the user decide.
- Reviewers broadening scope ("let me also look at related file X") → stick to step 1's scope. Cross-file context is fine as input, but out-of-scope findings do not go into the final report.
- Using the main conversation to apply edits instead of a fresh implementer subagent → context pollution. The implementer should start clean from the approved fix list.
- Presenting a long raw dump of both reports instead of a consolidated merge → the user has to do the merge themselves, which is exactly what this skill is supposed to do.
