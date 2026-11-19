---
name: ship
description: Merge a PR to production ("ship it", "merge it", "go") or roll back ("revert", "roll back"), with guardrails. Use for any request to promote, merge, deploy, or undo a phone PR.
---

# Ship / revert

On Vercel, merging into the default branch **is** the prod deploy. Treat "ship it" as a production action.

Use only REST calls through `gh api`, because `gh pr` is blocked in cloud sessions (see `~/.claude/CLAUDE.md`). Below, `R` stands for `repos/{owner}/{repo}`.

## "ship it"
1. **Identify the PR.** Use the one from the current thread. Otherwise use the newest open PR labeled `phone`: `gh api "R/issues?labels=phone&state=open&sort=created" --jq '[.[]|select(.pull_request)][0]'`. Name it back to the user before you merge.
2. **Load the state:** `gh api R/pulls/{n}` gives the head sha, labels, mergeable state and body. Then `gh api R/commits/{sha}/check-runs` and `gh api R/commits/{sha}/status`.
3. **Refuse** if any of these is true, and give the reason in one line:
   - it's labeled `needs-desk`;
   - any check run is not `completed/success`, or the combined status is not `success`. This includes the Vercel preview deployment;
   - `mergeable` is false;
   - the skeptic's verdict in the PR's kit trailer is `fail`.

   These checks are the real gate: the private repo has no GitHub branch protection, so nothing else stops a bad merge. Never skip them, even if the user insists. If they insist, tell them to merge from the GitHub app themselves.
4. **Merge:** `gh api -X PUT R/pulls/{n}/merge -f merge_method=squash -f sha={head_sha}`. Passing the sha makes GitHub refuse the merge if anything was pushed after your checks.
5. **Report:** "Merged #n → prod deploying. Rollback: say 'revert #n'." Once the merge commit's status shows the prod deploy URL, add it.

## "revert #n" / "roll back"
1. Find the merge commit: the `merge_commit_sha` field from `gh api R/pulls/{n}`.
2. Run `git fetch origin && git switch -c phone/revert-{n} origin/main && git revert --no-edit {sha}`, then push the branch.
3. Open the PR: `gh api R/pulls -f title="Revert #{n}: {title}" -f head=phone/revert-{n} -f base=main -f body="Reverts #{n}. Why: {the user's reason}"`. Then add the labels `phone` and `revert`.
4. Reverts may ship as soon as checks are green. Tell the user it's ready for "ship it".
5. **Record the escaped defect:** `gh api R/issues/{n}/comments -f body="kit: escaped-defect: {one-line reason}"`. The weekly routine turns these comments into replay eval cases.

For an emergency, point the user to the Vercel dashboard's "Instant Rollback" on the phone. It's faster, but it doesn't change `main`, so still open the revert PR afterwards.
