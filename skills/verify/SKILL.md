---
name: verify
description: Runs the full Unity verification ladder for a feature — compile, console errors, EditMode/PlayMode tests, scene runtime check — and reports facts separately from human-judgment items. Use when the user says /first-playable:verify <feature>.
---

# Unity Verification

You are running Phase 6 of the FirstPlayable workflow. "It compiles" is not
"it works". Verification means walking the ladder below and reporting exactly
which rungs were confirmed, inferred, or skipped.

Read `references/unity-mcp.md` in this plugin first — it explains how to
discover what the connected MCP server can actually do, the **retry protocol**
for reload/compile gaps, and the **manual verification protocol** to use when
no MCP is available (guided user steps recorded as `VERIFIED (user-reported)`,
never silent skips). Test-running details are in `references/unity-testing.md`.

## Hard rule: never edit code while play mode is running

Entering play mode and then editing a script deadlocks the session: Unity
defers the recompile, MCP refuses every command while `isCompiling` is true,
and nothing can exit play mode except a human pressing Stop. If runtime
verification reveals a defect:

```text
exit play mode  →  edit  →  wait for compile  →  re-enter play mode
```

This applies to instrumentation scripts too — write them *before* entering
play mode, not while observing. (The `unity-guard` hook will ask if the
play-mode marker from bootstrap is present, but do not rely on the hook.)

## Verification ladder

1. Confirm Unity MCP connection (if unavailable, switch to the manual protocol from `references/unity-mcp.md`)
2. Wait for Unity compilation to finish
3. Check for **new** Console errors (diff against pre-change state, not absolute zero)
4. Check warnings — **mandatory, not optional.** Font/glyph, missing-reference,
   and serialization warnings are how rendering and wiring defects surface;
   tests routinely pass while these fail (see UI rule below)
5. Run EditMode tests for the feature
6. Run PlayMode tests for the feature
7. Open the target scene
8. Enter Play Mode (confirm frames actually advance — sample `Time.frameCount`
   twice; if it is identical, `runInBackground` is off and **every** runtime
   observation below is invalid)
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

### Runtime instrumentation: state the conditions, or it isn't VERIFIED

Agent-driven instrumentation runs under conditions a human player never
experiences — usually **no continuous input**, no camera manipulation, no
sustained collisions. Systems behave completely differently: velocities decay,
thresholds are never crossed, cooldowns never overlap.

Rules:

1. **Every runtime measurement must state its conditions** (input? duration?
   what was on screen?). A measurement whose conditions differ from real play
   is `INFERRED (measured with: no input)` — not `VERIFIED`.
2. **A negative conclusion can never be `VERIFIED` by instrumentation alone.**
   "X does not trigger" is indistinguishable from "I failed to create the
   conditions for X". Label it `UNVERIFIED` and put it in Manual Verification.
3. If a measurement contradicts what you expected from the code, suspect the
   measurement setup before rewriting the conclusion.

### UI text: string assertions do not verify rendering

A passing `Assert.That(label.text, Contains("생존"))` says nothing about what
appears on screen — the font may have no glyph for those characters and render
as boxes. Any feature that adds UI text requires **both**: a clean console
(no font/glyph warnings) **and** a visual check (screenshot or user
confirmation). String assertion alone → `INFERRED`, never `VERIFIED`.

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
- **Measurement conditions** (input, duration, what differs from real play)
## Diagnostic Changes Restored
- Values/scene state changed for diagnosis → restored? verified how?
## Manual Verification Required
- e.g. input responsiveness, camera feel, feedback readability
## Remaining Risks
```

## Completion — exit gate

Before writing the report:

1. **Restore every diagnostic change.** Values inflated to observe an effect
   (e.g. a freeze duration set to 30s to see it), temporarily disabled
   components, scene tweaks. Read the value back after restoring and put that
   confirmation in the report.
2. Anything you could not restore goes at the **top** of the report as
   `⚠ NOT RESTORED: <what, where>`. Never let it pass silently — a diagnostic
   value that reaches a commit is worse than a failed verification.

Then, if everything automatic passes, update the Feature Spec status to
`Verified` **for the automated portion** and hand the Manual Verification list
to the user. Suggest `/first-playable:playtest` after they play.
