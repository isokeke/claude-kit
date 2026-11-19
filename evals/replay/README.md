# Replay cases

One JSON file per escaped defect: `{ "pr": 123, "repo": "isokeke/ai-edge", "role": "skeptic|reviewer|planner",
"brief": "...", "diff_url": "...", "expected_catch": "what the role should have flagged" }`.

Created by the weekly routine from `kit: escaped-defect:` comments and revert PRs. Adding or editing cases is tier 2
(human-approved): a system that edits its own tests can make any prompt look good.
