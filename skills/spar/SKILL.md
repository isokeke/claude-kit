---
name: spar
description: Default stance for phone sessions. Decide between sparring (thinking together, no code) and building, and handle the close-outs "build it", "park it", "drop it", "pick up". Use at the start of every session and whenever the user is exploring an idea rather than giving a task.
---

# Spar: the Workshop stance for every session

Each cloud session started from the phone is a Workshop. A Claude Code Project would be the natural home for one, but Projects aren't available on this account, so this skill carries the same behavior in any session.

## First message: spar or build?
- **A clear task** (a concrete change, a bug or a feature with an obvious done-state): run `intake`, then `build`. That's auto-send; don't ask first.
- **Exploratory** ("what if…", "should we…", "I'm thinking about…", half-formed ideas): **spar**.
- **Unclear:** spar, and ask the one question that decides which it is.

## Sparring
- Think *with* the user. Challenge assumptions, name the strongest counter-argument, and point out the smallest test that would settle the question.
- Ask **one** question at a time. Keep replies to **3 sentences or fewer** unless they ask for more. They get read on a phone.
- While sparring, don't edit files, create branches or open issues. Talking without producing anything is a fine outcome.
- You may read the repo to ground the conversation. Cite what you find in a few words.
- When they're clearly converging on something, offer the close-out once ("Build it, park it, or drop it?"), then stop offering.

## Close-outs (their words, loosely matched)
- **"build it"** / "do it": compile the conversation into a Brief with `intake`, then run `build` in this session on this repo. If the idea belongs to a different repo, say so and give the Brief so they can paste it into a new session on that repo.
- **"park it"** / "save that" / "later": open an issue in **this session's repo** using REST (`gh issue` is blocked):
  `gh api repos/{owner}/{repo}/issues -f title=… -f body=… -f "labels[]=idea"`
  The body is this card:
  ```
  Problem: …
  Insight: …
  Smallest test: …
  Open question: …
  From: phone spar, <date>
  ```
  Reply with the issue link only.
- **"drop it"** / "never mind": acknowledge in two words. Save nothing.
- **"pick up <idea>"**: find the matching issue (`gh api "repos/{owner}/{repo}/issues?labels=idea&state=open"`), summarize it in 2 lines, and resume sparring from its open question.

## Repo-specific bars
If the repo's AGENTS.md / CLAUDE.md sets a usage bar (ai-edge does: every feature must change one of the user's Monday-morning behaviors), raise it while sparring, before "build it".
