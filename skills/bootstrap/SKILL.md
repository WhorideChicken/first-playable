---
name: bootstrap
description: Safely sets up a Unity 6 project for the FirstPlayable workflow — preflight checks, folder structure, scenes, asmdefs, and a project CLAUDE.md. Always dry-runs first. Use when the user says /first-playable:bootstrap.
---

# Unity Project Bootstrap

You are running Phase 4 of the FirstPlayable workflow: preparing a Unity
project. **Safety over convenience** — this skill must be idempotent and must
never destroy existing work.

Before doing real work, read `references/unity-setup.md` in this plugin — it
has the detailed editor-settings checks, asmdef dependency rules, package
guidance, scene-creation fallbacks, and the idempotency checklist. Ready-made
asmdef JSON files, a Unity `.gitignore`, and the `PROJECT_STATUS.md` template
are in `templates/unity/`.

## Hard rules

- Show the full plan of changes (dry-run) and get user approval **before**
  creating or modifying anything.
- Never overwrite an existing file without explicit consent.
- Modify Scenes and Prefabs only through Unity MCP or Editor API — never edit
  Unity YAML directly.
- Never touch `Assets/ThirdParty` originals, never delete or regenerate
  `.meta` files, never remove packages.
- Re-running bootstrap on an already-bootstrapped project must be a no-op plus
  a report of what already exists.

## Preflight checks

Report each as pass/fail/unknown before proposing changes:

- Is this a Unity project? Which Unity version? (target: Unity 6)
- Render pipeline (Built-in / URP / HDRP)
- Input System package present?
- Test Framework package present?
- Cinemachine in use?
- Git repository and a Unity-appropriate `.gitignore`?
- Editor settings: Visible Meta Files, Asset Serialization = Force Text
- Unity MCP connection available?
- Existing scenes and asmdefs that could conflict

## Project modes

Ask which mode fits (default `Standard`):

| Mode | For | Structure |
|---|---|---|
| Prototype | game jams, quick validation | minimal folders, single asmdef, minimal docs |
| Standard | solo / small team | Core, Gameplay, Presentation, Tests split |
| Modular | long-term / team | per-feature module asmdefs |

## What gets created (Standard)

```text
Assets/
├─ _Game/
│  ├─ Art/  Audio/  Configs/  Prefabs/
│  ├─ Scenes/
│  │  ├─ Bootstrap/      # init & shared services
│  │  ├─ Gameplay/       # FirstPlayable scene lives here
│  │  └─ Test/           # Sandbox + automated/manual verification
│  ├─ Scripts/
│  │  ├─ Core/  Gameplay/  Presentation/  Infrastructure/  Editor/
│  └─ Tests/
│     ├─ EditMode/
│     └─ PlayMode/
└─ ThirdParty/
```

Plus, at the project root:

- `CLAUDE.md` — project rules (source-of-truth order, Unity rules, verification
  checklist). Use this plugin's `templates/CLAUDE.project.md` as the base. If a
  CLAUDE.md already exists, propose a merged diff instead of replacing it.
- `Docs/PROJECT_STATUS.md` — current phase, what is playable, what is next.

## Completion

Done when the structure exists, preflight issues are either fixed or explicitly
accepted by the user, and `CLAUDE.md` is in place. Then suggest
`/first-playable:feature <first-feature>` following `Docs/Design/DEVELOPMENT_ORDER.md`.
