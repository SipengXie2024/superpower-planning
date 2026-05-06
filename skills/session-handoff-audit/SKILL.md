---
name: session-handoff-audit
description: Generate a self-contained audit prompt for a fresh session to independently verify the implementation state of a long-running project. Use whenever the user asks to "start a new session", "hand off to next session", "audit what we've done", "verify implementation state", "check for drift", "防止幻觉", "跨会话交接", "核实实现状态", "新会话审计", "生成交接提示词", or is wrapping up a long development session and wants a fresh context-free session to independently verify the work against design specs. Trigger proactively after multi-commit implementation sessions where hallucination risk is high, even if user only says "下一个会话怎么接". Generates a copy-paste prompt; does NOT perform the audit itself.
---

# Session Handoff Audit Prompt Generator

## What this skill produces

A self-contained prompt text that the user copies into a fresh Claude session. That fresh session — with no memory of the prior conversation — reads the current codebase and independently verifies what has been implemented, detects drift from design specs, and returns an evidence-based report citing `file_path:line_number` for every claim.

The goal is to catch hallucinations. The current session has accumulated summaries, claims, and memory entries that may diverge from ground truth (the code). A fresh session reading source directly can expose those gaps.

## When this is worth doing

- Long development session crossing multiple commits, plans, or review loops
- User suspects their memory / findings files may have drifted from reality
- Before closing a session, to leave a clean baseline for the next one
- Before a critical milestone where "what's actually done" must be reliable
- After rapid iteration where it's unclear which findings were later superseded

If the session only produced a trivial change (one commit, small diff), this skill is overkill — just summarize normally.

## Core principles of the generated prompt

Every generated prompt must enforce these, otherwise the audit loses its value:

1. **Ground truth is source code.** Memory files, session summaries, progress logs, planning docs are hints only. Any conflict resolves to the code.
2. **Parallel subagent dispatch.** The audit splits across 2-4 `Explore` subagents that run in a single message. Sequential reads are slow and allow early findings to bias later ones.
3. **Evidence-first.** Every claim — "X is implemented", "parameter Y defaults to Z", "this drifted from spec" — comes with `file_path:line_number`. Statements without line refs are rejected by the report reviewer.
4. **Three-axis audit.** (a) implementation inventory: what exists and is wired to production, (b) parameter defaults: do literal values match spec, (c) drift: deviations including additions the spec never mentioned.
5. **Uncertainty is a first-class output.** Things that need runtime observation to verify (e.g., "this hook really fires at block boundary in production") are flagged as uncertainties, not guessed.

## Workflow

### Step 1: Gather context

Use `AskUserQuestion` to collect:

- **Repository root** (absolute path). Default: current working directory if inside a git repo.
- **Branch name**. Default: current branch from `git branch --show-current`.
- **Design spec location**. Common patterns: `.planning/design.md` + `.planning/design/*.md`, `docs/design/`, `spec/`, `DESIGN.md`, `CLAUDE.md`. Ask user to pick the authoritative one.
- **Memory / progress file paths**. Common patterns: `~/.claude/projects/<encoded-path>/memory/*.md`, `.planning/findings.md`, `.planning/progress.md`, `NOTES.md`. Mark these as "hints, not authority" in the generated prompt.
- **Audit scope**. Options to offer: full project, specific phase or module, last N commits, specific files. This steers the task split sent to subagents.
- **Subagent count**. Suggest 3 as default. Scale up to 4 if the project has clearly independent modules; down to 2 if small.

If the prior conversation already contains these facts (repo mentioned, branch visible in gitStatus, phase markers in use), extract them and just confirm with a single summary question rather than asking each separately.

### Step 2: Fill the template

Read `assets/audit_prompt_template.md`. Substitute the collected fields into the `{{PLACEHOLDER}}` slots. If that file is missing or unreadable, fall back to the embedded minimal template below. The template is designed to stand alone — do not prune its sections, they each carry weight:

- **Context block** establishes paths and the "don't trust summaries" clause
- **Goal** defines the three-axis audit
- **Task breakdown suggestions** show subagent division examples; customize to match the project's actual layout
- **Execution constraints** enforce parallelism, evidence, uncertainty flagging
- **Output format** gives the new session a rigid structure so comparison is easy
- **Integration hint** at the end tells the user how to use the returned report

If the project has no design docs (pure code, just CLAUDE.md, or just a README), adapt:
- Replace "design spec" verification with "coding convention adherence"
- Use `CLAUDE.md` + README as the closest spec
- Drop the parameter-defaults axis (nothing to check against), keep inventory + drift

#### Fallback template (use when `assets/audit_prompt_template.md` is missing)

```text
You are auditing the implementation state of {{REPO_PATH}} on branch {{BRANCH}}. Ground truth is source code; design docs and memory files are hints, not facts.

Design spec: {{SPEC_PATH}}
Progress notes (hints only): {{PROGRESS_PATH}}, {{MEMORY_PATH}}
Audit scope: {{SCOPE}}

Method: dispatch {{N_SUBAGENTS}} Explore subagents IN PARALLEL in a single message. Each must return file:line citations for every claim. No claim without a citation. Flag uncertainty as "UNCERTAIN: <reason>" — do not guess.

{{SUBAGENT_TASK_BREAKDOWN}}

Required output:
1. Implementation inventory — what exists and is wired in (cite file:line per item).
2. Parameter defaults — every literal value in code vs the spec (or "drop this axis" for bench-only / no-spec projects).
3. Drift — code that contradicts spec, or additions the spec never mentioned.
4. Uncertainty list — anything that needs runtime observation to verify.

Do not propose fixes. Do not import claims from prior conversations. Do not summarize what was "already done".
```

Substitute the fields collected in Step 1. The `{{SUBAGENT_TASK_BREAKDOWN}}` slot is where customization patterns (multi-phase / monorepo / bench-only) get applied.

### Step 2.5: Verification checkpoint

Before presenting the prompt to the user, scan the filled template for completeness:

- **No unfilled `{{PLACEHOLDER}}` slots remain.** Grep the prompt text for `{{`; if any matches, the field was missed in Step 1 — return to gather it before proceeding.
- **All five required sections present**: Context (paths + ground-truth clause), Goal (3-axis), Task breakdown (subagent dispatch), Constraints (parallelism + evidence + uncertainty), Output format (rigid structure for diff-ability).
- **Customization actually applied** when the project has a non-default shape: monorepo → per-crate subagents listed by name, multi-phase → phase numbers wired into subagent scope, bench-only → parameter-defaults axis dropped not just renamed, no design docs → README/CLAUDE.md substituted.
- **No anti-patterns leaked**: search the prompt for "continue from previous", "already done", "summary of progress", "recommend next steps". If any present, rewrite that section.

If any check fails, fix before Step 3. The audit's value is determined by these gates — a sloppy prompt produces a sloppy report.

### Step 3: Present the prompt

Output the filled prompt inside a single fenced code block (```), ready to copy. Below the block, 2-3 sentences on:
- Where to paste (a fresh Claude session in the same repo)
- Rough duration (10-15 min for the audit to complete)
- How to interpret: discrepancies between the new session's report and the current session's claims localize the hallucinations

Do not include multiple code blocks. A single block is easier to copy reliably.

## Customization patterns

**Multi-phase projects** (Phase 0/1/2/...): ask which phases to audit. The generated prompt then scopes each subagent to a phase.

**Monorepo**: suggest one subagent per crate group or package.

**Design split across chapter files**: add a line in the generated prompt: "read the design index first, then pull specific chapters as needed — do not load all chapters upfront".

**Test-heavy projects**: add a dedicated test-coverage axis to the output format.

**Bench-only projects** (no production target, like research code): replace "wired to production path" with "exercised by a benchmark or test binary"; list the benchmark entry points.

## Example — what a hallucination caught looks like

Session A's `progress.md` wrote: "Implemented `parse_block_with_retries` at `parser.rs`, retries 3× with exponential backoff, wired into `executor::run_block:142`."

Session B (audit) returned: function exists at `parser.rs:88` ✓; retry count is **5 not 3** (`parser.rs:91`); backoff is **linear not exponential** (`parser.rs:103-107`); wired at `executor.rs:178` not 142 — line 142 is unrelated. Three concrete claims each subtly wrong; none would be caught by re-reading the summary, only by independent code read with file:line evidence.

## Anti-patterns to avoid in the generated prompt

- Telling the new session to "continue from where the previous session left off" — that imports hallucinations
- Including a summary of what was "already done" — the whole point is independent verification
- Asking the new session for recommendations or planning — this skill is audit-only
- Loading the entire memory folder into the new session's context — that's the contamination vector

## Output format

The main deliverable is the fenced prompt. Keep any commentary around it minimal and factual. Do not add motivational framing or preamble — the user has already decided to run the audit.
