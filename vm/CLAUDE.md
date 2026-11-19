# claude-kit (user-level, cloud VM)

The user works from their phone. They read on a small screen and usually can't see a terminal, so:
- Keep messages short and lead with the result. Link to PRs and previews instead of pasting diffs.
- When a request arrives as raw dictation, run the `intake` skill first. It turns the request into a Brief, which you show before acting.
- When the request is to build something, run the `build` skill. It runs the planner → implementer → skeptic → reviewer pipeline.
- For "ship it", "merge", "revert" or "roll back", run the `ship` skill.
- At the start of anything you build, check that `~/.claude/.kit-version` exists. If it's missing, run `bash ~/claude-kit/kit-sync.sh`. It's the fallback for when the SessionStart hook didn't run.

## GitHub from a cloud session
The cloud GitHub proxy blocks GraphQL. That means `gh pr …`, `gh issue …` and `gh search …` fail with a 403.
- Use the REST API through `gh api` (or the built-in GitHub tools) instead. Examples:
  - **Create a PR:** `gh api repos/{owner}/{repo}/pulls -f title=… -f head=… -f base=… -f body=…`
  - **Add labels:** `gh api repos/{owner}/{repo}/issues/{n}/labels -f "labels[]=phone"`
  - **Merge:** `gh api -X PUT repos/{owner}/{repo}/pulls/{n}/merge -f merge_method=squash`
  - **Checks:** `gh api repos/{owner}/{repo}/commits/{sha}/check-runs` and `…/commits/{sha}/status`
  - **Comment:** `gh api repos/{owner}/{repo}/issues/{n}/comments -f body=…`
  - **Find PRs:** `gh api "repos/{owner}/{repo}/issues?labels=phone&state=open"` (PRs are the items with a `pull_request` key)
- The proxy only serves repos attached to this session. If you get a 403 that says `is not enabled for this session`, tell the user which repo to attach.
- Branch deletion is rejected by the proxy. Don't try it; the repos auto-delete head branches on merge.

Engineering guidelines apply to every repo:
@~/claude-kit/rules/engineering.md

The repo's own CLAUDE.md / AGENTS.md overrides these guidelines wherever they conflict.
