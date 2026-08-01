---
name: feature
description: Spec-first feature development for Unity — writes a Feature Spec referencing game rule IDs, gets approval, then implements pure logic, tests, and Unity integration in that order. Use when the user says /first-playable:feature <name>.
---

# Feature Spec & Implementation

You are running Phase 5 of the FirstPlayable workflow. **Never implement a
feature without an approved spec.** The spec — not the conversation — defines
what "done" means.

## Order of work

```text
read design docs (Docs/Game, Docs/Design)
→ survey related code and packages already in the project
→ write the Feature Spec (Draft)
→ user approves the spec
→ implement pure C# logic (no UnityEngine dependencies where possible)
→ EditMode tests for the pure logic
→ Unity integration (MonoBehaviours, scenes, prefabs via MCP/Editor API)
→ PlayMode tests
→ hand off to /first-playable:verify
```

Only implement what the approved spec includes. If mid-implementation you
discover the spec is wrong, stop, update the spec, and get re-approval — do not
quietly diverge.

## Feature Spec

Location: `Docs/Features/<FEATURE_NAME>.md` (template:
`templates/features/FEATURE_SPEC.md`).

```markdown
# Feature: Player Movement

## Status
Draft | Approved | Implementing | Verified

## Purpose
## Player's perspective
## Referenced rules
- MOVE-001          # every behavior must trace to a GAME_RULES.md ID

## In scope
## Out of scope
## Behavior rules
## Initial tuning values
| Item | Value | Status |
|---|---:|---|
| Move speed | 5 | TEMPORARY |

## Done conditions
## EditMode tests
## PlayMode tests
## Manual play checks     # things only a human can judge (feel, readability)
## Open questions
```

## Scene wiring order (recompilation drops inspector references)

Assigning inspector references and *then* editing scripts loses those
assignments: the domain reload can null out serialized fields, and the scene
looks wired while the game does nothing. Always:

```text
edit scripts  →  confirm compile finished  →  wire the scene  →  save
              →  read the references back and log them
```

Every scene-wiring Editor script must ship with a `Verify()` that re-reads what
it just assigned and logs the result. Cheap to write, and it catches both this
failure and typo'd lookups immediately.

## Implementation rules

- Read `references/unity-testing.md` in this plugin before implementing — it
  covers the humble-object split (pure logic in `Game.Core`, thin
  MonoBehaviour adapters), EditMode/PlayMode test patterns, common PlayMode
  pitfalls, and what NOT to test.
- Follow the asmdef boundaries set up by bootstrap; check them before adding code.
- Tuning values marked `TEMPORARY` go in serialized fields or configs — never
  scattered magic numbers.
- Include the referenced rule ID in test names or descriptions
  (e.g. `Move001_KnockbackSuppressesInput`).
- Scene/Prefab changes go through Unity MCP or Editor API only.

## Default feature order (from DEVELOPMENT_ORDER.md)

input → movement → camera → core action → interaction targets → win/lose → restart

One feature per invocation. Finish and verify before starting the next.
