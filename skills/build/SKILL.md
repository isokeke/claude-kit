---
name: build
description: Run the planner → implementer → skeptic → reviewer pipeline for a Brief, ending in a PR with a Vercel preview. Use for any "build it" or implement request after intake has produced a Brief.
---

# Build pipeline

You orchestrate this pipeline. You don't do the roles' work yourself. Hand off through files, never through your own summary, so that each role judges the artifacts in front of it rather than another role's reasoning.

## Setup
1. If there's no Brief yet, run `intake` first.
2. Create the branch `phone/<short-slug>` off the default branch.
3. Write the Brief to `.kit/brief.md`. Read the kit version from `~/.claude/.kit-version`; if the file is missing, run `bash ~/claude-kit/kit-sync.sh` first.
4. `.kit/` is scratch space for the pipeline. Make sure it's in `.git/info/exclude` so it never gets committed.

## Pipeline
1. **Planner** (`planner` agent). Input: `.kit/brief.md`. Output: `.kit/plan.md`.
2. **Skeptic, plan pass** (`skeptic` agent, mode `plan`). Input: brief + plan. Output: appends to `.kit/verdicts.json`.
   - On a fail, send the findings back to the planner. This can happen once at most; a second fail escalates.
3. **Implementer** (`implementer` agent). Input: brief + plan. Output: commits on the branch, plus `.kit/checks.log`, which holds the raw output of every check command.
4. **Skeptic, diff pass** (`skeptic` agent, mode `diff`). Input: brief, plan, `git diff <base>...HEAD`, `.kit/checks.log`. The skeptic re-runs the checks itself.
   - On a fail, send its findings to the implementer. Allow at most **2 loops**. After that, stop and escalate.
5. **Reviewer** (`reviewer` agent). Input: brief, plan, diff, verdicts. It either returns blocking findings (send them to the implementer; this counts against the same 2-loop budget) or approves and opens the PR.
6. Report to the user in **3 lines or fewer**: the PR link, the preview link once Vercel posts it, and the single most important thing to check in the preview.

## Escalation
Stop the pipeline and ask the user when any of these happens:
- the loop budget runs out;
- the plan is classed `needs-desk`;
- the planner and the skeptic disagree about what the Brief means.

Ask **one** question that can be answered in a sentence.

## Role trailer
The reviewer adds this to the end of the PR body. Fill it in from `.kit/verdicts.json` and from what happened in the run:

````
<details><summary>kit trailer</summary>

```json
{
  "kit_version": "<sha>",
  "size": "S|M|L",
  "needs_desk": false,
  "roles": {
    "planner": {"model": "...", "replans": 0},
    "implementer": {"model": "...", "loops": 0},
    "skeptic": {"model": "...", "plan_verdict": "pass", "diff_verdict": "pass",
                "findings": [{"id": "s1", "claim": "...", "evidence": "...", "resolved": "fixed|overridden|n/a"}]},
    "reviewer": {"model": "...", "blocking": 0, "nits": 0}
  },
  "intake_corrections": 0
}
```
</details>
````

Label the PR `phone`. Add `needs-desk` too if the plan says so.
