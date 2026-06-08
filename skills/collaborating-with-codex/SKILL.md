---
name: collaborating-with-codex
description: Use when delegating coding work — prototyping, debugging, analysis, review, implementation, or generating publication-quality scientific/architecture diagrams — to Codex CLI. Supports multi-turn sessions via SESSION_ID.
---

> **MANDATORY: ALWAYS run codex_bridge.py in the background.**
> When invoking `codex_bridge.py` via the Bash tool, you MUST set `run_in_background: true`.
> Codex calls typically block for 60-120 seconds. Running them in the foreground freezes the
> entire conversation. Never omit this flag. No exceptions.
>
> **Sandbox policy:** `--sandbox read-only` is rejected at the argparse layer. When
> `--sandbox workspace-write` is requested, the bridge first probes bubblewrap by calling
> `bwrap --unshare-user --unshare-net --unshare-pid --ro-bind / / true` (result cached for
> 5 minutes at `/tmp/codex_bridge_bwrap_probe.<uid>`). If the probe fails — typically
> `bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted` on Ubuntu 24.04+ with
> restricted unprivileged user namespaces, or in containers without `CAP_NET_ADMIN` — the
> bridge **auto-downgrades to `danger-full-access`** and writes a warning to stderr with the
> fix command (`sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0`). Set
> `CODEX_BRIDGE_SKIP_BWRAP_PROBE=1` to bypass the probe when you know the host is fine. The
> default `danger-full-access` mode never runs the probe.

## Quick Start

```bash
python3 scripts/codex_bridge.py --cd "/path/to/project" --PROMPT "Your task"
```

**Inside the `superpower-planning` plugin**, the bridge script lives at
`${CLAUDE_PLUGIN_ROOT}/skills/collaborating-with-codex/scripts/codex_bridge.py`.
Always use that absolute path when invoking the bridge from another skill in this plugin
(e.g. `subagent-driven-codex`).

**Output:** JSON with `success`, `SESSION_ID`, `agent_messages`, and optional `error`.

## Workflow

1. **Scope.** Decide what to delegate and the workspace root. In → the user's ask; out → one task and a `--cd` path. If a path looks wrong or may not exist, keep it as an assumption to flag (step 3), not a reason to stall.
2. **Confirm if it can write.** In → the planned dispatch; out → user go-ahead, or a skip when work is clearly read-only / already authorized this turn (see "Confirm before a destructive run" below).
3. **Dispatch in background.** In → task + `--cd` (+ `--skip-git-repo-check` for non-repo dirs); out → run `codex_bridge.py` with `run_in_background: true`. Name any path/topology assumption alongside the call.
4. **Capture `SESSION_ID`.** In → the JSON response; out → the `SESSION_ID` string, kept for every follow-up turn on this task (see Multi-turn Sessions).
5. **Verify, then report.** In → `agent_messages` / returned diff; out → a checked result. Verify before treating it as done; never apply unreviewed changes. Report only what the bridge actually returned, in plain prose.

**Confirm before a destructive run.** Codex executes with `danger-full-access` by default, so it can edit, delete, or run arbitrary commands in `--cd`. Before the first dispatch that can write the user's tree — and always before `--yolo` or before applying a returned diff — state in one line what you're about to delegate and where, then get the user's go-ahead. Skip the gate only for clearly read-only work (analysis, review, "return a diff only / do not modify files" prompts) or when the user already authorized the action this turn. After Codex returns, verify the diff or result before treating it as done; never apply unreviewed changes.

**Grounding (never fabricate an outcome):** Only report what the bridge actually returned. Do not claim Codex "ran", "failed", or hit a specific error (e.g. "No such file or directory") before you have invoked the bridge and read its output — manufacturing a failure to justify stalling is worse than proceeding (see steps 1 and 3 on flagging a doubtful path instead of blocking). When you report, address the user directly in plain prose; do not surface flag names, `SESSION_ID` UUIDs, or other bridge machinery as user-facing meta.

## Parameters

```
usage: codex_bridge.py [-h] --PROMPT PROMPT --cd CD [--sandbox {workspace-write,danger-full-access}] [--SESSION_ID SESSION_ID] [--skip-git-repo-check]
                       [--return-all-messages] [--image IMAGE] [--model MODEL] [--yolo] [--profile PROFILE]

Codex Bridge

options:
  -h, --help            show this help message and exit
  --PROMPT PROMPT       Instruction for the task to send to codex.
  --cd CD               Set the workspace root for codex before executing the task.
  --sandbox {workspace-write,danger-full-access}
                        Sandbox policy for model-generated commands. Defaults to `danger-full-access`. `read-only` is intentionally removed — see the Sandbox policy note above. `workspace-write` runs a bwrap preflight and silently downgrades to `danger-full-access` when bubblewrap cannot initialize on this host.
  --SESSION_ID SESSION_ID
                        Resume the specified session of the codex. Defaults to `None`, start a new session.
  --skip-git-repo-check
                        Allow codex running outside a Git repository (useful for one-off directories).
  --return-all-messages
                        Return all messages (e.g. reasoning, tool calls, etc.) from the codex session. Set to `False` by default, only the agent's final reply message is
                        returned.
  --image IMAGE         Attach one or more image files to the initial prompt. Separate multiple paths with commas or repeat the flag.
  --model MODEL         The model to use for the codex session. This parameter is strictly prohibited unless explicitly specified by the user.
  --yolo                Run every command without approvals or sandboxing. Only use when `sandbox` couldn't be applied.
  --profile PROFILE     Configuration profile name to load from `~/.codex/config.toml`. This parameter is strictly prohibited unless explicitly specified by the user.
```

## Multi-turn Sessions

**Always capture `SESSION_ID`** from the first response for follow-up:

```bash
# Initial task
python3 scripts/codex_bridge.py --cd "/project" --PROMPT "Analyze auth in login.py"

# Continue with SESSION_ID
python3 scripts/codex_bridge.py --cd "/project" --SESSION_ID "uuid-from-response" --PROMPT "Write unit tests for that"
```

## Common Patterns

**Prototyping (request diffs, do not apply):**
```bash
python3 scripts/codex_bridge.py --cd "/project" --PROMPT "Generate unified diff to add logging. Do not write the changes to disk."
```
Note: the sandbox still defaults to `danger-full-access`. Enforce read-only behavior through the prompt ("do not modify files", "return a diff only") rather than through `--sandbox`, because `read-only` is blocked.

**Debug with full trace:**
```bash
python3 scripts/codex_bridge.py --cd "/project" --PROMPT "Debug this error" --return-all-messages
```

**Generate publication-quality figures (Claude can't render raster images — Codex can):**
```bash
python3 scripts/codex_bridge.py --cd "/project" --PROMPT "Use your imagegen-scientific-schematics skill to create a publication-style architecture diagram. Components: API gateway, auth service, Postgres. Solid arrows for sync calls, dashed for async. Save the final PNG to docs/figures/arch.png in this workspace and report the path."
```
Codex runs its `imagegen-scientific-schematics` skill (built-in `image_gen`) for scientific schematics, architecture/data-flow diagrams, and paper figures — work Claude has no native tool for. Two musts in the prompt: (1) name the skill and spell out exact labels, layout, and arrow semantics; (2) tell Codex to save the final image into the `--cd` workspace, otherwise it stays under `~/.codex/generated_images/` where Claude can't read it. Reuse `SESSION_ID` to iterate on the same figure.
