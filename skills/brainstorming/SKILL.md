---
name: brainstorming
description: Explores a design space before any code is written, surfacing the decisions that actually matter and their tradeoffs, then persists the approved design and plan into .planning/. Use when a feature is multi-step or still ambiguous, when a new component needs shaping, or when the approach itself is the open question rather than the implementation, including "帮我理一理", "该怎么设计", "有哪些方案".
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

**Say what you are doing, in the user's terms, not the skill's name:** "Working through the design space before any code gets written."

Start by understanding the current project context, then ask questions to refine the idea. Once you understand what you're building, present the design and get user approval.

Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.

## Checklist

You MUST create a task for each item and complete them in order. The terminal state is a persisted plan at `.planning/plan.md`; do NOT write code or invoke an implementation skill before it exists.

1. **Explore project context (iterative retrieval).** Don't scan once. Loop to progressively discover context:

   **Cycle 1, broad sweep:**
   - Scan project structure (Glob for key directories and file patterns) and search request keywords (Grep)
   - Read project docs, README, CLAUDE.md, `CONTEXT.md` (the project's ubiquitous language, if present), recent commits
   - Check `.planning/archive/*.md` for relevant history; if found, note relevant Key Decisions and Lessons Learned under a `## Historical Context` section
   - Save initial findings to `.planning/findings.md`

   **Evaluate and identify gaps:**
   - Score each file/component **High** (directly implements the target), **Medium** (related patterns or types), or **Low** (tangential, exclude from further exploration)
   - Ask "what do I still not understand about how this integrates?" and note the codebase's own terminology (it may differ from the request wording)

   **Cycles 2-3, targeted refinement (only if gaps remain):**
   - Search using codebase-native terminology; follow imports, type definitions, and call chains from high-relevance files; read complete implementations, not just grep snippets
   - Update `.planning/findings.md` after each cycle (2-Action Rule)

   **Stop when** 3+ high-relevance files are understood and no critical gaps remain, or after 3 cycles. Depth over breadth: 3 deeply understood files beat 10 skimmed ones.
2. **Scope check.** Determine whether the request describes multiple independent subsystems. If yes, propose decomposition first and brainstorm only the first sub-project through this flow.
3. **Ask clarifying questions.** One question at a time via `AskUserQuestion`, multiple choice preferred; focus on purpose, constraints, and success criteria. Record key answers and decisions to `.planning/findings.md`.
4. **Propose 2-3 approaches** via `AskUserQuestion`. Lead with your recommended option and why; include trade-offs in each option.
5. **Present design** in sections scaled to complexity (a few sentences to 200-300 words), getting approval after each section via `AskUserQuestion`.
   - Cover architecture, components, data flow, error handling, and testing.
   - Design for clear boundaries and small, focused files; if a file has grown unwieldy, include a split when it serves the current task.
   - **Evidence-first:** back every decision (architecture, performance assumption, complexity trade-off, interface contract) with evidence (benchmarks, data, references, reasoned analysis). When evidence is not available yet, mark it `[NEEDS-EVIDENCE]` inline and continue. Don't block to gather evidence, don't silently assume.
6. **Write design doc** to `.planning/design.md`. Initialize `.planning/` first if needed (`${CLAUDE_PLUGIN_ROOT}/scripts/init-planning-dir.sh`), populate the Task Status Dashboard in `progress.md` from the design, and move exploration findings (rejected approaches, discovered constraints, useful references) into `findings.md`.
7. **Spec self-review** with fresh eyes, fixing inline (no re-review needed):
   - **Placeholders:** any "TBD", "TODO", or vague requirement? Fix them.
   - **Consistency:** do any sections contradict each other? Does the architecture match the feature descriptions?
   - **Scope:** focused enough for a single implementation plan, or does it need decomposition?
   - **Ambiguity:** could a requirement be read two ways? Pick one and make it explicit.
8. **Spec interview.** Ask: "Do you want to run a spec interview to refine details in the design?" (default: yes). If yes, invoke `superpower-planning:spec-interview` with the design doc as target; when it returns, resume this checklist. If the user skips, continue directly. Either way, the next step is the user review gate below.
9. **User review gate.** Explicitly ask the user to review the written spec before planning.
10. **Ask about worktree** via `AskUserQuestion`: isolate implementation in a git worktree? If yes, use Claude Code's native worktree support (e.g. `EnterWorktree`); skip if no. `.planning/` is gitignored, so a fresh worktree starts without it: copy the directory across (`cp -r .planning <worktree>/`) before step 11, or the plan you are about to write lands in an empty planning directory, separated from the design doc and findings written in step 6.
11. **Transition to implementation.** Write the plan to `.planning/plan.md`: bite-sized, verifiable tasks with exact file paths, real code and commands, and verification steps. This persisted plan is the terminal step; `spec-interview` and worktree isolation are the only allowed intermediate steps before it.

## Key Principles

- **Always use `AskUserQuestion`** for user-facing questions, one question per call. Multiple choice is easier to answer than open-ended.
- **YAGNI ruthlessly.** Remove unnecessary features from every design.
- **Evidence-first.** Every decision needs evidence; no evidence yet means mark `[NEEDS-EVIDENCE]`, never silently assume.
- **Ubiquitous language.** When design talk coins or resolves a domain term, record it in the repo-root `CONTEXT.md` on the spot (`superpower-planning:domain-glossary`) and use canonical terms in the design doc.
- **Iterative retrieval.** Start broad, score relevance, refine with codebase-native terms, max 3 cycles, depth over breadth.
- **Explore alternatives.** Always propose 2-3 approaches before settling, and validate incrementally by getting approval per section.
- **Large systems must decompose** into independent subsystems; keep files small with explicit boundaries before planning.
- **Be flexible.** Go back and clarify when something doesn't make sense.
