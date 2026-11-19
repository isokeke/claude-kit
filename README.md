# claude-kit

Phone-first build loop: **voice → spar → build / park / drop → preview → ship.** This repo holds the prompts, roles and rules behind it, and the self-update loop that improves them.

```
Action Button → Workshop project (spar) ─┬─ drop it → nothing
                                         ├─ park it → idea issue here
                                         └─ build it → intake Brief → cloud thread
   build: planner → skeptic(plan) → implementer → skeptic(diff) → reviewer → PR + Vercel preview
   ship it → REST merge → prod     revert #n → revert PR + escaped-defect → replay eval
weekly routine → metrics + ≤3 evidence-backed prompt edits (tier 1 auto / tier 2 you approve)
```

| Path | What | Tier |
|---|---|---|
| `workshop/instructions.md` | Workshop project persona and close-outs | 1 |
| `skills/intake/` | Dictation → Brief | 1 |
| `agents/{planner,implementer,reviewer}.md` | Build roles | 1 |
| `agents/skeptic.md` | Bullshit detector | **2** |
| `skills/build/`, `skills/ship/` | Pipeline and prod guardrails | **2** |
| `rules/engineering.md` | Engineering guidelines | **2** |
| `evals/`, `routines/`, `.github/` | Tests, the improver, the gate | **2** |

**Tier 1** changes auto-merge, but only when CI's replay suite shows no regression and `evals/replay/` holds at least 5 cases. `.github/workflows/tier-gate.yml` enforces this.
**Tier 2** changes always need the owner's approval.

## One-time setup (~30 min at a desk)

### 1. Repo + GitHub
- This repo is **public**, because cloud sessions fetch it without GitHub auth. Keep personal details out of it; they go only in the Workshop instructions you paste into claude.ai.
- Install the Claude GitHub App on `ai-edge` (and `claude-kit` for parking ideas and the routine) (https://github.com/apps/claude). Cloud sessions need it to clone private repos, and auto-fix needs it too.
- Create these labels in both repos: `phone`, `needs-desk`, `revert`. In claude-kit, also create `idea`, `kit-auto`, `kit-review`, `kit-rejected`.

### 2. Cloud environment (claude.ai/code → environment settings)
1. Open https://claude.ai/code. On the new-session screen, select the **first control in the row under the message box** (the environment selector).
2. Under **Cloud**, hover over the environment you use, usually **Default**, and select its **settings icon**. Alternatively, select **New environment** and name it `kit`.
3. **Network access:** Limited, with **Allow package managers** checked. raw.githubusercontent.com is on the default allowlist, and that's all the kit needs.
4. **Setup script:** paste this:
   ```bash
   #!/bin/bash
   curl -fsSL https://raw.githubusercontent.com/isokeke/claude-kit/main/kit-sync.sh -o /tmp/kit-sync.sh \
     && bash /tmp/kit-sync.sh --bootstrap || true
   ```
5. Select **Save changes** (or **Add environment** if it's new).

The kit is fetched as plain files (listed in `MANIFEST`) from raw.githubusercontent.com, not cloned. That way it works in a session on *any* repo, even when `claude-kit` isn't attached. The SessionStart hook installed by `--bootstrap` re-fetches the kit on every session, so kit changes arrive without touching the environment again.

**Day-1 check:** start a session on ai-edge and send `cat ~/.claude/.kit-version && ls ~/.claude/skills`. You should see a version hash and `build intake ship`. If the hook didn't run, `vm/CLAUDE.md` tells `build` to run `kit-sync.sh` itself.

### 3. Workshop project (Claude app → Code → Projects)
- Create a project called **Workshop**. Attach `ai-edge` and `claude-kit`, and select the environment from step 2.
- Paste `workshop/instructions.md` (below the line) into Project settings → Memory → Project instructions.
- Project threads **don't** load repo `.claude/skills`. The kit reaches them through the setup script (`~/.claude`). As a fallback, also enable the `intake`, `build` and `ship` skills on claude.ai.
- **No Projects on your account (beta)?** You don't need them. The `spar` skill makes every cloud session a Workshop: a new session on a repo starts in sparring mode, and "build it" builds in that session. Point the iPhone Shortcut at `https://claude.ai/code` instead.

### 4. iPhone: one tap to talk
- Shortcuts app → New Shortcut "Spar" → action **Open URLs** → the Workshop project's URL (copy it from the share menu at claude.ai/code).
- Settings → Action Button → Shortcut → "Spar". Optionally add Back Tap (Accessibility → Touch → Back Tap) or a lock-screen widget.
- **Day-1 check:** does real-time voice mode work inside the Code tab? If not, use keyboard dictation (🎙). For walk-and-talk, use a regular chat project called "Spar" with the same instructions; its close-out produces a Brief you paste into Workshop.

### 5. Per repo (ai-edge first)
- CI workflow: lint, typecheck, test, build (see `ai-edge/.github/workflows/ci.yml`).
- Branch protection on `main`: require CI and the Vercel deployment check, and no force push.
- Vercel Git integration on: PRs get a preview, `main` goes to prod.

### 6. Weekly routine
In a Claude Code session, run `/schedule` and create a weekly task on `claude-kit` using the prompt from `routines/weekly-improve.md`.

## Verification drills
These are in the plan's Verification section: the front-door drill, a phone dry run with the Mac off, a rollback drill, the needs-desk guardrail, auto-fix, the skeptic plant, and self-update.
