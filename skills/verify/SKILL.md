---
name: verify
description: Runs the full Unity verification ladder for a feature — compile, console errors, EditMode/PlayMode tests, scene runtime check — and reports facts separately from human-judgment items. Use when the user says /first-playable:verify <feature>.
---

# Unity Verification

You are running Phase 6 of the FirstPlayable workflow. "It compiles" is not
"it works". Verification means walking the ladder below and reporting exactly
which rungs were confirmed, inferred, or skipped.

## Verification ladder

1. Confirm Unity MCP connection (if unavailable, say so and report which steps below become impossible)
2. Wait for Unity compilation to finish
3. Check for **new** Console errors (diff against pre-change state, not absolute zero)
4. Check related warnings
5. Run EditMode tests for the feature
6. Run PlayMode tests for the feature
7. Open the target scene
8. Enter Play Mode
9. Inspect the key objects and state transitions the Feature Spec names
10. List everything that could NOT be automatically verified

## Evidence labels

Label every claim in the report:

| Label | Meaning |
|---|---|
| `VERIFIED` | Confirmed by test run or actual execution |
| `INFERRED` | Deduced from code/config, not executed |
| `UNVERIFIED` | Not checked |
| `MANUAL_REQUIRED` | Only a human playing can judge this |

Never present `INFERRED` as `VERIFIED`. If a test could not run, that is
`UNVERIFIED` with a reason — not a pass.

## Report

Write to `Docs/Reports/<DATE>_<FEATURE>_VERIFICATION.md` (template:
`templates/reports/VERIFICATION_REPORT.md`):

```markdown
# Verification Report

## Scope
## Compilation
- Status / new errors / new warnings
## EditMode Tests
- Passed / failed (with names)
## PlayMode Tests
- Passed / failed (with names)
## Runtime Verification
- Scene checked, objects checked, state changes observed
## Manual Verification Required
- e.g. input responsiveness, camera feel, feedback readability
## Remaining Risks
```

## Completion

If everything automatic passes, update the Feature Spec status to `Verified`
**for the automated portion** and hand the Manual Verification list to the
user. Suggest `/first-playable:playtest` after they play.
