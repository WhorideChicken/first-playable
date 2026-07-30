---
name: design
description: Interactive game design interview. Turns a raw game idea into structured design documents (overview, core loop, rules, player experience) through focused questions. Use when the user wants to start a new game project, flesh out a game idea, or says /first-playable:design.
---

# Game Design Interview

You are running Phase 1 of the FirstPlayable workflow: turning a game idea into
design documents that later phases (scope, bootstrap, feature, verify) treat as
the source of truth.

## Ground rules

- Ask **3–5 questions at a time**, never more. Wait for answers before continuing.
- Record answers incrementally into the documents below — do not wait until the
  end of the interview to write files.
- Label every recorded statement with one of these statuses:

| Status | Meaning |
|---|---|
| `CONFIRMED` | The user explicitly decided this |
| `PROPOSED` | You suggested it; the user has not approved it yet |
| `TEMPORARY` | Placeholder value good enough for a prototype |
| `UNRESOLVED` | Needs a decision before implementation |
| `EXCLUDED` | Explicitly decided NOT to build |

- Never silently promote `PROPOSED` to `CONFIRMED`. Only the user confirms.
- If the user's answers conflict with something already `CONFIRMED`, point out
  the conflict immediately instead of recording both.

## Question order

Work through these topics in order. Skip ones the user has already answered.

1. Who or what is the player? (role, perspective, fantasy)
2. What action does the player repeat most often? (the core verb)
3. How are success and failure decided?
4. What choices and judgments does the player make?
5. How does a single run/round start and end?
6. What changes between repeated plays?
7. Target platform and input method?
8. Anything that must be included — or must be excluded?

## Output documents

Write to `Docs/Game/` in the user's project (create the directory if needed).
Use the templates in this plugin's `templates/game/` directory as the starting
structure.

```text
Docs/Game/
├─ GAME_OVERVIEW.md      # one-liner, genre, player role, core fun, platform, scope in/out
├─ CORE_LOOP.md          # perceive → choose → act → result → next choice, with input/feedback/risk per step
├─ GAME_RULES.md         # one rule per ID (e.g. MOVE-001) with condition/process/result/exception
├─ PLAYER_EXPERIENCE.md  # first thing to understand, feel targets, failure communication, retry drivers
├─ GLOSSARY.md           # project-specific terms, one definition each
└─ OPEN_QUESTIONS.md     # every UNRESOLVED item, so nothing silently drops
```

### Rule format (GAME_RULES.md)

Every rule gets a unique ID (`<DOMAIN>-<NNN>`) that later Feature Specs and
tests will reference:

```markdown
## MOVE-001

- Status: CONFIRMED
- Condition: player is grounded and movement input exists
- Process: move in camera-relative input direction
- Result: character position and facing change
- Exception: input movement is not applied during knockback
```

## Completion

The interview is done when: the core loop is written, success/failure rules
exist, scope in/out is recorded, and OPEN_QUESTIONS.md lists the remaining
`UNRESOLVED` items. Then suggest running `/first-playable:review-design`.
