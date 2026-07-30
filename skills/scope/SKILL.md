---
name: scope
description: Defines the First Playable — the smallest playable build that proves the core fun — including success/failure conditions, development order, and playtest hypotheses. Use after design review approval, or when the user says /first-playable:scope.
---

# First Playable Scope

You are running Phase 3 of the FirstPlayable workflow. A First Playable is not
the whole game — it is the **minimum build in which the core fun can be
directly played and judged**. Prerequisite: `Docs/Game/DESIGN_REVIEW.md` is
`Approved`. If it is not, stop and point the user to `/first-playable:review-design`.

## Include (default yes)

- Player input
- Core movement or the core action
- The minimum set of interaction targets
- A success condition and a failure condition
- Restart
- Only the UI/feedback needed to understand what is happening

## Exclude (default no — record under Excluded, don't argue each one)

- Content unrelated to validating the core fun
- Final art quality
- Multiple maps or characters
- Long-term progression systems
- Shops and monetization
- Live-ops features
- Abstractions "for future expansion"

If the user insists on including an excluded-by-default item, record it but flag
it under Scope Risks.

## Output documents

Write to `Docs/Design/` (templates in this plugin's `templates/design/`):

```text
Docs/Design/
├─ FIRST_PLAYABLE.md        # core fun to validate, start/end state, in/out scope, success/failure/done conditions, manual checks
├─ DEVELOPMENT_ORDER.md     # ordered feature list: input → movement → camera → core action → targets → win/lose → restart
└─ PLAYTEST_HYPOTHESES.md   # falsifiable hypotheses (HYP-001 ...) about why this is fun
```

### Hypothesis format

Each hypothesis must be falsifiable by watching someone play:

```markdown
## HYP-001

### Hypothesis
The player enjoys controlling the direction and strength of physics-based pushes.

### How to validate
- Does the player retry after failing?
- Do they use a different strategy on the next attempt?
- Do they attribute the outcome to their own input?

### Failure signals
- The outcome feels random to them.
- They say luck matters more than control.
- They do not retry after the first failure.
```

## Completion

Done when all three documents exist, every included feature traces to a rule ID
in `GAME_RULES.md`, and at least one hypothesis exists. Then suggest
`/first-playable:bootstrap` (requires an open Unity project).
