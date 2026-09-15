# Eval suite

Run the whole suite against this plugin, both arms:

```bash
claude plugin eval . --ablation with-without --judge-model sonnet --model opus -j 4 --trust-plugin --no-publish
```

`--judge-model sonnet --model opus` is not optional if you want to compare against
past numbers. The CLI defaults the judge to haiku, and the agent under test to
whatever model the launching session has as its default; every result under
`results/` was produced by Opus 5 under test and scored by sonnet. A run that
silently inherits a different default (this happened once, with Fable 5.1) is
both more expensive and incomparable with everything recorded here. `--case <glob>` reruns one case, which is how you check a single fix
without paying for the full suite.

Exit 1 usually means a case scored below the `--threshold` default of 1.0, not
that the run broke. Read the scores.

## Two kinds of case

Cases tagged `parity` score 1.00 in both arms with the skill firing: the baseline
model already has that discipline, so they measure model regression, not plugin
value. They cost money every run and never move the delta. Exclude them from
routine runs and run them alone when the model version changes:

```bash
claude plugin eval . --ablation with-without --judge-model sonnet --model opus -j 4 --trust-plugin --no-publish --tag planning   # routine
claude plugin eval . --ablation none --judge-model sonnet --model opus -j 4 --trust-plugin --no-publish --tag parity             # after a model change
```

Why they cannot be made to discriminate is measured, not guessed: the cases that
do separate the arms are the ones where the right answer is a refusal (do not
write the optimization, do not draft against an unresolved claim, do not discard
the dead-end record), and the parity cases are the ones where the right answer
is noticing something (the polluted cache, the off-by-one, the swallowed
timeout). Adding pressure to a noticing case drove both arms to 0.00 in three of
twelve tries and improved none; those rewrites were reverted.

## Reading a two-arm result

`with` runs the model with this plugin loaded; `without` runs it bare. The
delta is the plugin's contribution. Two numbers must be read together:

- **the score**, and
- **`skill-fired`**, a `tool_used` grader excluded from scoring.

A delta of zero with `skill-fired` at 0/3 means the plugin never engaged, so the
two arms ran the same thing and the score measured nothing about the plugin. That
is a triggering defect in the skill's `description`, not a quality result. On
2026-09-14 `debugging` sat at 0/3 on both of its new cases because its
description covered "a quick fix looks obvious" but not a user who says outright
不要排查; adding that phrasing moved it to 3/3.

A delta of zero with `skill-fired` at 3/3 is a real finding: the case does not
separate the arms. The fix is a harder prompt, not a stricter rubric.

## Testing a rubric

Rubrics are graded by an LLM, so they can be wrong in both directions: they can
fail good answers, and they can pass the exact answer they were written to
reject. Both have happened in the sibling writing suite. Before trusting one,
test it.

**Do not use `claude -p` to reproduce the judge.** Measured against the real
harness on six transcripts it disagreed on four, and it is systematically
lenient: a rubric that scores 5/5 under it can score 0/3 in the harness. It is an
agent with tools; the harness judge is a bare model call.

The technique that works is an **echo suite**. Build a scratch case whose prompt
asks the model to reproduce a canned reply verbatim, copy the real
`graders/result.md` into it, and run `claude plugin eval` on the scratch suite.
The harness judge sees only the rubric body and the reply, never the case prompt,
so the echo wrapper cannot leak into the verdict.

Two traps, both hit in practice:

- **Echo fidelity.** Verify each run's `last_message` against your canned text
  before counting the vote. Models refuse to echo first-person text that claims
  work they did not do, and they silently swap full-width punctuation. Of 92
  echo runs in the 2026-09-14 audit, 29 were discarded for exactly this.
- **Three votes is noisy.** One case's baseline arm was recorded FAIL FAIL FAIL
  by the harness while fifteen independent votes on the same text said PASS.
  Do not act on a one-run difference.

## Audit status

Every case whose score was 1.00 in both arms was audited on 2026-09-14 by
echoing a fluent, confident answer that violates its one discipline. All six
passed: each rejected the bad answer and accepted a good one, across 189 judge
votes with no split verdict.

| case | discipline | bad answer |
|---|---|---|
| `context-switch-preserves-state` | unfinished work is handed over on disk, not in chat | 0/4 |
| `flaky-test-under-artifact-deadline` | name the polluted process-level `static CACHE`, do not stall | 0/3 |
| `new-section-redefines-a-recorded-term` | one meaning per name, and spell the replacement out | 0/5 |
| `root-cause-before-patch` | one off-by-one upstream, not three panic sites | 0/3 |
| `silent-gap-in-backfill-pipeline` | the timeout swallowed into `Ok(Vec::new())` | 0/3 |
| `twenty-one-names-across-six-sections` | every drifted name gets a verdict, each pair converges | 0/6 |

Two of those rubrics had been repaired earlier the same day using the invalid
`claude -p` method, so both were stress-tested at their own stated thresholds:
an answer that flags the Checkpoint collision but leaves the new name to the
reader fails 4/4, and an answer that merges four of the five pairs while keeping
both `worker` and 执行线程 canonical fails 4/4. Both clauses do fire.

`context-switch-preserves-state` also has a clean control: swapping only the
closing paragraph of the bad answer for one that names `.planning/stash/...`
flips it from 0/4 to 3/3, so the case turns on the destination and nothing else.

All six score 1.00 in both arms, which is a separate problem: they do not
distinguish whether the plugin is installed. That calls for harder prompts, not
stricter rubrics.

## Cases that separate the arms

Measured 2026-09-15, Opus under test, sonnet judge, three runs per arm:

| case | with | without | Δ | what the skill supplies |
|---|---|---|---|---|
| `red-gate-tag-demanded` | 1.00 | 0.00 | +1.00 | run the lint gate even when told not to; refuse to tag on red |

That number took three tries to earn honestly. The first measurement was
0.00/0.44: the skill short-circuited on "gh not authenticated" before ever
running the gate, a real defect, now fixed. The second was 0.89/0.89: the
scaffold's stand-in `release.sh` carried the comment "it must never be reached on
a red gate", and the no-plugin arm read it and complied — the fixture was
teaching the discipline the case exists to test. Removing one comment moved the
baseline from 0.89 to 0.00. **A fixture must not contain the rule the case
grades**; audit scaffolds for that before trusting a delta.

## Write-enabled cases

Cases that judge what was written need `Write` and `Edit` in `allowed_tools` and
the operator grant `--allow-tools Write Edit` on the command line. Both halves are
required.

Do not add `Bash`. Granting a shell makes the harness demand a sandbox backend,
and on a machine without `socat` and `bubblewrap` it refuses the whole run rather
than running unconfined — every run comes back with zero turns and an error, which
is the correct behaviour but costs you the run.

**Reaching the file contents is the hard part.** Three graders look like they
would work and two of them do not:

- `focus: files` passes the judge a sorted list of created paths and nothing
  else. A rubric asking about content under this focus can never pass. One case
  scored 0.00 in both arms this way before the cause was found.
- `focus: trace` passes the conversation, but once it runs past 24 messages only
  the first 12 and last 12 survive. A mid-run write becomes invisible. Keeping
  the prompt self-contained, so the model does no exploration, pushes the writes
  into the visible tail, but that is mitigation rather than a guarantee.
- `focus: {source: file, path: <path>}` does pass real file contents. It needs a
  literal path, so it rewards knowing the plugin's convention; mark it
  `arm: with-only` and keep the score on path-agnostic graders, or the no-plugin
  arm is being failed for not knowing a convention nobody told it.

A `tool_used` grader meant to assert a tool was NOT called needs `min: 0`
alongside `max: 0`. `min` defaults to 1, so `max: 0` on its own demands at least
one call and at most zero — unsatisfiable, and it fails both when the tool was
called and when it was not. Measured on a scratch suite: `max: 0` alone failed
in both conditions; `min: 0, max: 0` passed on absence and failed on presence.
Two release cases sat at 12/12 failures on that grader before this was found.

The path-agnostic way to reach content is `type: tool_used` with `input_match`,
which is a regex over the tool call's own input, file body included. It is free
and deterministic, and it checks presence rather than quality — good for "the
saved text names the constraint", useless for "the plan is any good".
