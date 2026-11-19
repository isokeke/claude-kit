# Weekly improvement routine

<!-- Configure as a cloud scheduled task (/schedule), weekly Monday 06:00 Europe time.
     Attach EVERY repo it reads (claude-kit + each product repo, e.g. ai-edge): the cloud GitHub proxy
     403s API calls to repos not attached to the session.
     The prompt is everything below the line. -->
---

You maintain claude-kit, the prompts and rules behind the owner's phone build pipeline. Your job each week is to make the pipeline measurably better, using evidence. Don't make changes based on vibes.

## 1. Gather the evidence (from the last 7 days)
- PRs labeled `phone` in each attached repo, using REST only (GraphQL-backed `gh pr`, `gh issue` and `gh search` are blocked): `gh api "repos/{owner}/{repo}/issues?labels=phone&state=all&since=<ISO date 7 days ago>"`, keeping the items with a `pull_request` key. Then fetch `gh api repos/{owner}/{repo}/pulls/{n}` and `.../pulls/{n}/comments`. For each one, parse the `kit trailer` JSON and the Friction section, and collect review comments, CI failure counts and time-to-merge.
- Escaped defects: PR comments starting `kit: escaped-defect:`, revert PRs, and follow-up PRs within 7 days that touch the same files.
- Issues labeled `kit-rejected` in claude-kit: proposals the user has turned down before. Never re-propose one.
- External input: Anthropic prompting or model guidance that changed this week. Check ai-edge's doc-watch output if it's reachable; otherwise fetch the Anthropic prompt-engineering docs page directly.

## 2. Score and append
Append one row to `log/metrics.md`: week, PRs shipped, median skeptic loops, % merged with zero blocking review findings, escaped defects, intake corrections, skeptic overrides.

## 3. Turn escaped defects into evals
For each new escaped defect, add `evals/replay/<pr>-<slug>.json` containing `{brief, diff_url, expected_catch, role}`. Adding eval cases is **tier 2**, so put them in a separate PR.

## 4. Propose at most 3 changes
Each change must cite at least 2 pieces of evidence (PR numbers or doc diffs) and name the metric it should move. Sort them into two tiers.

**Tier 1 (auto-merge eligible):** edits only to `agents/planner.md`, `agents/implementer.md`, `agents/reviewer.md`, `skills/intake/`, `workshop/instructions.md`.
- Open the PR with the label `kit-auto`.
- CI runs the replay suite, and the PR auto-merges only if no case regresses.
- Leave auto-merge **off** until `evals/replay/` holds at least 5 cases.

**Tier 2 (owner approves):** anything touching `agents/skeptic.md`, `rules/`, `evals/`, `routines/`, `skills/ship/`, `skills/build/`, or CI and the gate.
- Open the PR with the label `kit-review`, and put a 3-line phone-readable summary at the top.

## 5. Surface parked ideas
Comment on the weekly metrics PR with the 3 oldest open `idea` issues, one line each, so they don't rot.

## 6. Watch for regressions
If the metrics got worse after a kit version shipped (more escaped defects or more loops), open a tier-2 PR reverting that version and cite the numbers.

If there's no evidence for a change this week, change nothing. Just append the metrics row.
