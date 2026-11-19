---
name: intake
description: Turn raw dictated speech into a precise Brief before acting. Use whenever a request reads like voice dictation (filler words, run-ons, "that thing", self-corrections), or at the start of any build request from the phone.
---

# Intake: from dictation to Brief

The user dictates on their phone, often while walking, so their messages contain transcription errors, half-finished thoughts and corrections mid-sentence ("no wait, actually…"). Your job is to recover what they *meant* and write it down so the next step can act on it without guessing.

## Steps
1. **Clean up.**
   - Drop filler words.
   - Where they correct themselves, keep only the final version.
   - Fix likely transcription errors using what's in the repo. For example, "super base" means Supabase and "next" means Next.js. Check names against real files, routes and functions.
2. **Resolve references.** Turn "that page", "the feed thing" or "like last time" into concrete paths, using the repo, recent commits, open PRs and project memory. If a reference fits more than one thing, pick the most likely one and record it as an assumption.
3. **Write the Brief** in exactly this shape, and print it first, before you do anything else:

```
**Brief**: <repo>
Goal: <one sentence, user-visible outcome>
Context: <why this matters / what prompted it, 1–2 lines>
Constraints: <bullets: tech, style, things to keep>
Done when:
- [ ] <checkable criterion: observable behavior, test, or route>
- [ ] …
Non-goals: <what we are explicitly not doing>
Verify: <commands + preview route to check>
Assumptions: <anything you inferred; the user corrects these after the fact>
Size: S | M | L   needs-desk: yes/no (see rules/engineering.md §13)
```

4. **Then act.** Don't wait for approval; the user chose auto-send. If they correct an assumption, update the Brief, say what changed, and carry on.

## How to write a good Brief
These follow Anthropic's prompting guidance for current Claude models: be explicit, give the reason, and define success.
- **Done-when lines must be observable.** "The feed loads faster" doesn't work. "The /feed TTFB in the preview is below 300ms, measured with `curl -w`" does. Each line has to be something the skeptic can check.
- **State the reason** in Context. A model that knows why something is wanted makes better calls on edge cases than one that only has the instruction.
- **Phrase constraints as what to do.** Write "Use the existing `src/lib/prompts` helpers" rather than "don't write new prompt code".
- **Keep non-goals concrete.** They're what stops the planner from over-scoping.
- **Size:** S means one file and an obvious change. M means several files or a new test surface. L means a new subsystem or several PRs; for L, propose splitting it into multiple Briefs.
- If the request is something to think about rather than build ("should we…", "what if…"), **don't write a Brief**. Answer as a sparring partner instead.

## Signals for the weekly routine
When the user corrects an assumption, add one line to the PR's Friction section, e.g. `intake: misread "feed" as /feed, meant /practice`. Those lines are what improve this skill.
