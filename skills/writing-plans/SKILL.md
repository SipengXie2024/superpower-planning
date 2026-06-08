---
name: writing-plans
description: Use when a spec or requirements exist for a multi-step task and an implementation plan needs to be written before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

Address the user directly; never name this skill, its steps, internal scripts/tools, or named rules ("Scope Check", "no-placeholders rule"). Give the reasoning in plain terms ("this bundles several independent subsystems, so I'll split it") rather than citing the rule.

**Context:** Optionally runs in a dedicated worktree (user chooses during brainstorming).

**Save plans to:** `.planning/plan.md`

## Scope Check

If the spec covers multiple independent subsystems, stop and suggest splitting it into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure First

Before defining tasks, map out which files will be created or modified and what each one is responsible for.

- Design units with clear boundaries and well-defined interfaces
- Each file should have one clear responsibility
- Prefer smaller, focused files over large files that do too much
- Files that change together should live together
- Split by responsibility, not by technical layer
- In existing codebases, follow established patterns, but if a file you are already touching has become unwieldy, a targeted split is reasonable

This file-structure pass should happen before task decomposition.

## Historical Archive Check

Before writing the plan, check for relevant historical archives:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/archive-search.sh "<keyword>"
```

1. If relevant archives are found, read the full archive directory (especially `summary.md`, `findings.md`) and incorporate relevant lessons into the plan
2. If none are relevant or no archives exist, skip silently

Run this silently — don't narrate the script path or the search to the user; just fold any findings into the plan.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** Execute using the chosen execution mode (see end of plan).
> Planning dir: .planning/

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```

> **Note:** Log unexpected discoveries, technical decisions, and implementation insights to `.planning/findings.md` after each task.
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

**This bans laziness, not drafting under partial inputs.** When the design is summarized, partial, or some paths/signatures are not yet confirmed, still write the full plan — concrete file map, real test code, real commands — using your best inferred values, and tag each unconfirmed value with a `[VERIFY]` marker plus a one-line note on what to check. A complete plan with explicit `[VERIFY]` markers is the deliverable; refusing to produce plan artifacts because inputs are imperfect is a worse outcome than a clearly-hedged plan. Only stop short of a plan when the spec is genuinely absent (then say what is missing) or the Scope Check fires.

## Auto-Create `.planning/` Directory

When writing a plan, **automatically create** the `.planning/` directory if it does not already exist by running:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh
```

This creates `progress.md` and `findings.md`. The canonical template is at `planning-foundation/templates/progress.md`. Delegated role planning directories (`agents/`) are created when needed.

Run this silently too — don't surface the script path or describe the setup mechanics to the user.

> **Note:** The plan in `.planning/plan.md` is the single source of truth for plan content. Execution status is tracked via the Task Status Dashboard in `progress.md`.

## Parallelism Groups

**Every plan MUST include a parallelism analysis** after the task list. Identify which tasks can run in parallel (no shared files, no sequential dependencies) and group them:

````markdown
### Parallelism Groups

- **Group A** (parallel): Task 1, Task 2, Task 3
- **Group B** (after Group A): Task 4, Task 5
- **Group C** (after Group B): Task 6

**Parallelism score:** 3/6 tasks can run in parallel in the first group
````

**Tips for maximizing parallelism:**
- Split work along file boundaries (each task edits different files)
- Split work along module boundaries (each task touches a different subsystem)
- Extract shared setup into an early serial task, then parallelize the rest
- If a task can be split into independent subtasks, split it

The parallelism score helps the user choose the right execution mode.

## Self-Review

After writing the complete plan, review it yourself with fresh eyes. This is a checklist you run inline — not delegated dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Evidence gaps:** Are `[NEEDS-EVIDENCE]` items from the design tracked and properly timed in the Evidence Gap Summary?

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Evidence Tracking

Before writing tasks, scan the design doc (`.planning/design.md`) for all `[NEEDS-EVIDENCE]` markers. For each one:

1. **Classify timing:** before implementation (blocking) / during implementation / after MVP
2. **Define what's needed:** benchmark, data analysis, reference check, prototype, etc.
3. **Assign to a task:** "before implementation" items become prerequisite tasks in the plan; others are noted inline in the relevant task

Include an **Evidence Gap Summary** section in the plan:

````markdown
### Evidence Gap Summary

| # | Decision | Evidence Needed | Timing | Task |
|---|----------|----------------|--------|------|
| 1 | ... | ... | Before impl | Task 0 |
| 2 | ... | ... | During impl | Task 3 |
````

If no `[NEEDS-EVIDENCE]` markers exist in the design, skip this section silently.

## Remember
- Exact file paths always
- Complete code in every step — no placeholders (see "No Placeholders" section)
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits
- Each task reminds: "Log discoveries, decisions, and insights to `.planning/findings.md`"
- Always include parallelism groups analysis
- Lock file boundaries and responsibilities before task decomposition

## Execution Handoff

After saving the plan and completing the self-review, you MUST present exactly these three options using `AskUserQuestion`. Do NOT omit, replace, or invent options. All three MUST always be shown regardless of your analysis.

**Use `AskUserQuestion` with these exact options:**

**1. Claude Code Dynamic Workflow** — Native workflow execution for large, parallel, or cross-checked work. Best when the plan has independent task groups, broad review/audit needs, or would otherwise require many Claude workers.

**2. Codex-Driven (this session, sequential)** — best when the user wants a second model to implement and review bounded tasks through Codex CLI.

**3. Manual Batch Session** — best when dynamic workflows are unavailable or the user wants explicit checkpoint summaries between batches.

Keep the option labels and descriptions plain; do not put internal skill identifiers (`superpower-planning:...`) into the text the user reads. The sub-skill to invoke for each choice is named only in the "If X chosen" branches below, which are internal routing notes, not user-facing.

Include your recommendation in the question text based on the logic below, but never remove options.

**Recommendation logic (add "(Recommended)" to the best option's label):**
- High parallelism score + heavy tasks or review/audit fan-out → recommend Claude Code Dynamic Workflow
- User wants a second-model executor/reviewer → recommend Codex-Driven
- User wants manual checkpoints or workflow support is unavailable → recommend Manual Batch Session

**If Claude Code Dynamic Workflow chosen:**
- Ask Claude to run a workflow that executes `.planning/plan.md` (include the word "workflow" in the request so Claude writes one), or switch to `/effort ultracode` when the user wants automatic workflow orchestration.
- Make the workflow read `.planning/design.md`, `.planning/plan.md`, and `.planning/findings.md` as source context.
- Ask the workflow to write durable discoveries and final execution evidence back into `.planning/findings.md` and `.planning/progress.md`.

**If Codex-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use `superpower-planning:subagent-driven-codex`
- Stay in this session
- Route implementer and reviewer roles through Codex CLI via the bridge.

**If Manual Batch Session chosen:**
- Guide them to open a new session in a worktree if needed
- **REQUIRED SUB-SKILL:** New/manual session uses `superpower-planning:executing-plans`
