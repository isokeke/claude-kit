# Engineering guidelines

These are rules, not suggestions. Each one can be checked. Changing this file requires the user's approval (tier 2).

## Definition of done
1. Before you claim a change is done, run typecheck, lint, tests and build in the session, and quote the final line of each output.
2. A behavior change ships with a test that fails without the change. A test that only renders or only mocks the thing you changed doesn't count.
3. A UI change ships with a screenshot or a description of the Vercel preview at the affected route. Put it in the PR.
4. The PR meets every "Done when" line in the Brief. Tick each line explicitly in the PR body.

## Scope
5. Make the smallest change that meets the Brief. Write down unrelated improvements under "Follow-ups" in the PR; don't make them.
6. One concern per PR. If a PR goes past ~400 changed lines (excluding lockfiles and generated files), split it.
7. Extend existing modules and utilities before creating new ones. The plan has to name what it reuses.
8. Add a new dependency only with a one-line justification in the PR saying why existing code or the platform can't do it.

## Truthfulness
9. Don't write stubs, placeholder data, `TODO: implement`, or swallowed errors (`catch {}`) in shipped code. If you can't finish something, say so in the PR instead of faking it.
10. Don't use an API from memory when the installed package ships docs. Check `node_modules/<pkg>/docs` or its types first. This matters most for Next.js (see the repo's AGENTS.md).
11. Never edit a test to make it pass unless the Brief changed the expected behavior. If you do, say so in the PR.

## Safety
12. Never commit secrets, tokens or `.env` files. Read config through the existing env helpers.
13. Changes to DB migrations or schema, env vars or infra, auth/permissions, payment, or cron schedules get the label `needs-desk`. Never merge those from the phone.
14. Never force-push to `main`, rewrite published history, or skip CI.
15. Roll back by reverting the PR. Don't push fix-forward commits straight to `main`.

## Communication
16. The PR body has these sections: Brief, Plan, Outcome, Friction, Follow-ups, plus the role trailer (see the `build` skill).
17. Friction means anything in this session that cost a loop: a wrong assumption, a missing doc, a flaky check, an unclear Brief. Write "none" if there wasn't any. The weekly routine learns from this section.
