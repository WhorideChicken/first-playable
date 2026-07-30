---
name: playtest
description: Structures raw play feedback into observations, hypotheses, and a single-variable next experiment; updates Feature Specs when changes are confirmed. Use after the user plays a build, or when they say /first-playable:playtest.
---

# Playtest Structuring

You are running Phase 7 of the FirstPlayable workflow: converting natural-
language play feedback into something actionable. The user says things like
*"turning feels slippery and the camera lags a bit"* — your job is to separate
what they **observed** from what might **cause** it, and to design the smallest
next experiment.

## Rules

- Observations are what the player felt/saw — record them verbatim-ish, without
  explaining them away.
- Hypotheses are candidate causes — there are usually several per observation.
  Never jump straight from feeling to fix.
- The next experiment changes **one variable at a time**. If the user reports
  two problems (movement + camera), fix them in separate experiments so the
  results are attributable.
- Every experiment needs success criteria written **before** the change is made.

## Record format

Write to `Docs/Playtests/YYYY-MM-DD_<FEATURE>.md` (template:
`templates/reports/PLAYTEST_REPORT.md`):

```markdown
# Playtest

## Observation
- Stopping distance feels long when reversing direction.
- Camera follow lag is noticeable.
- Top speed feels right.

## Hypotheses
- Deceleration time may be too long.
- Rotation interpolation may be too slow.
- Camera damping may be too high.

## Next Experiment
1. Keep top speed unchanged.
2. Change deceleration time only.
3. Re-check movement feel, then tune the camera separately.

## Success Criteria
- Reversal input gets a fast response.
- Movement does not feel choppy.

## Related
- Feature Spec: PLAYER_MOVEMENT.md
- Hypotheses: HYP-001
```

## Closing the loop

When an experiment's result is confirmed by the user:

1. Update the tuning table in the related Feature Spec (value + why it changed).
2. If the change altered a game rule, update `GAME_RULES.md` and note which
   features/tests are affected.
3. If it validated or falsified a `PLAYTEST_HYPOTHESES.md` entry, record that.
4. If a significant design/tech decision was made, record it in
   `Docs/Decisions/NNNN-<slug>.md` (template: `templates/decisions/DECISION.md`).
