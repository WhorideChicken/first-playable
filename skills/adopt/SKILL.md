---
name: adopt
description: Brings FirstPlayable into a Unity game that is already in development — inventories the project, backfills design rules from the existing code as PROPOSED (with source citations) for the user to confirm, and installs the safety pieces without restructuring anything. Use instead of design/bootstrap when the project already has code and scenes, or when the user says /first-playable:adopt.
---

# Adopt an Existing Project

The other skills assume a game that starts at the design interview. Most real
projects don't: the code exists, the design lives in someone's head. This skill
is the side door. It ends where the normal workflow continues: the next feature
goes through `feature → verify → playtest` like any other.

> **Status:** new in v1.0 and not yet field-tested on a project other than its
> author's. Expect rough edges, and record them the way `examples/` records
> everything else.

## Hard rules

- **Read-only until the user approves a written plan.** Same dry-run rule as
  `bootstrap`.
- **Never restructure.** Don't move, rename, or re-folder existing scripts,
  scenes, or assets, and don't impose `Assets/_Game/`. The project's layout is
  the layout. (Moving assets is GUID-safe only through the Editor, and it is
  churn no one asked for.)
- **Code shows behavior, not intent.** Every rule recovered from code is
  `PROPOSED`, never `CONFIRMED`, and cites where it came from. The user decides
  whether a behavior is intended (→ `CONFIRMED`) or a bug (→ a fix task in
  `OPEN_QUESTIONS.md`).
- **Backfill only what you'll touch.** Document the core loop plus the systems
  the next features will change. Everything else stays undocumented until a
  spec touches it ("spec on touch"). Documenting a whole shipped game up front
  costs days and goes stale before it's read.

## Steps

### 1. Inventory (read-only)

Survey and summarize. Don't analyze deeply yet:

- Unity version, render pipeline, input system (new / legacy / both), packages
- Scenes and which one is the "play" scene
- Script layout: folders, asmdefs and their references, rough size per area
- Existing tests (EditMode / PlayMode), and whether they pass. Run them via the
  Unity CLI or MCP if connected (`references/unity-cli.md`)
- Existing docs: README, design notes, task trackers the user points to
- Tooling: Unity CLI / MCP connection, git status, `.gitignore`

Write `Docs/Adoption/INVENTORY.md` (one page). Ask the user which systems the
**next 2–3 features** will touch. That answer is the backfill scope.

### 2. Interview, short

Code can't tell you why the game is fun. Ask the design interview's first
questions only (who is the player, the core verb, how a run starts/ends, what
makes it fun). 3–5 questions, once. Write `Docs/Game/GAME_OVERVIEW.md`.

### 3. Backfill rules from code

For the core loop and the in-scope systems only, read the code and draft
`Docs/Game/CORE_LOOP.md` and `Docs/Game/GAME_RULES.md` using the normal rule
format, plus a source line:

```markdown
## DMG-001

- Status: PROPOSED
- Source: Assets/Scripts/Combat/DamageSystem.cs:42-61 (behavior as coded, 2026-10-12)
- Condition: projectile hits an enemy with health > 0
- Process: damage = base × (crit ? 2 : 1); subtract from health
- Result: enemy health decreases; at 0 → death event
- Exception: none found in code
```

Rules for backfilling:

- Write what the code **does**, including suspicious behavior. Don't clean it
  up into what it probably should do.
- Tuning numbers found in code are `TEMPORARY` unless the user says they're final.
- Behavior that looks like a bug (dead branch, inconsistent with another rule,
  magic number fighting a config value) goes to `OPEN_QUESTIONS.md` as a
  question, not into the rule.
- Systems outside the scope get one line in `CORE_LOOP.md` ("Inventory —
  exists, undocumented") so their absence is visible, not hidden.

Then walk the user through the `PROPOSED` rules a handful at a time. Each one
becomes `CONFIRMED`, changed, or a bug ticket. Then run
`/first-playable:review-design` as normal.

### 4. Install the safety pieces, not the structure

Run `bootstrap`'s preflight and **blocking checks only** (see that skill):
`runInBackground`, the `PlayModeMarker` (into the project's existing Editor
folder and asmdef, not a new tree), Unity CLI sign-in / pipeline package if the
CLI is used, and a `CLAUDE.md` merged into whatever exists. Skip folder and
asmdef creation entirely.

If the existing code has no testable seam (logic inside MonoBehaviours), don't
refactor it now. `feature` splits out pure logic for the code it touches, when
a spec needs a test. Nothing earlier.

### 5. Continue with the normal workflow

- Define the next milestone with `/first-playable:scope`. Treat it as a "next
  playable" rather than a first playable: the game already plays, so the
  question is what the next build must prove.
- Each upcoming change goes through `/first-playable:feature`, starting with a
  spec that references the now-confirmed rule IDs.

## Completion

Done when: `INVENTORY.md` and `GAME_OVERVIEW.md` exist; the core loop and
in-scope systems have rules the user has confirmed (or turned into tickets);
the safety pieces are installed; and the next feature has a Feature Spec draft.
