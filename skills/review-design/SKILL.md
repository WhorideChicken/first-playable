---
name: review-design
description: Reviews the game design documents in Docs/Game/ for contradictions, missing decisions, and scope risks before any implementation starts. Use after the design interview, or when the user says /first-playable:review-design.
---

# Design Review

You are running Phase 2 of the FirstPlayable workflow: a critical review of the
documents in `Docs/Game/` **before** any Unity work begins. You are a reviewer,
not a fixer — report problems; do not rewrite the design without being asked.

## Checklist

Evaluate each item and gather concrete evidence (quote the rule IDs or document
sections involved):

1. Is the core loop actually repeatable? (does the last step lead back to the first?)
2. Are success and failure conditions unambiguous?
3. Does the player make real choices, or is there one dominant strategy by design?
4. Do any rules contradict each other? (check exceptions against other rules' conditions)
5. Is anything included that does not serve the core fun?
6. Can the design be validated by actually playing it?
7. Are any important `UNRESOLVED` or `PROPOSED` items about to leak into implementation?
8. Is the excluded scope explicit?

## Output

Write `Docs/Game/DESIGN_REVIEW.md`:

```markdown
# Design Review

## Passed
- Items that passed, with a one-line reason each

## Conflicts
- Contradicting rules, referenced by ID (e.g. MOVE-001 vs DASH-002: ...)

## Missing Decisions
- Decisions that must be made before implementation

## Scope Risks
- Features likely to balloon scope, and why

## Approval
Draft | Approved
```

## Approval gate

- The review starts as `Draft`. Only the **user** flips it to `Approved`.
- If Conflicts or Missing Decisions are non-empty, walk the user through them
  one at a time and update the design documents with their decisions
  (marking each `CONFIRMED`), then re-run the checklist.
- Do not proceed to Unity setup or implementation while the review is `Draft`.
- Once `Approved`, suggest `/first-playable:scope`.
