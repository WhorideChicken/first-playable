# Unity MCP Reference

How FirstPlayable uses a Unity MCP server, and how to degrade gracefully
without one. FirstPlayable does **not** bundle or endorse a specific
implementation — it checks what capabilities are actually available and adapts.

## 1. Capabilities FirstPlayable wants

| Capability | Used by | For |
|---|---|---|
| Read console logs/errors | verify | "zero new errors" check |
| Trigger compilation / wait for it | verify | compile gate |
| Run EditMode/PlayMode tests | verify | test gates |
| Open scene / enter Play Mode | verify | runtime check |
| Inspect GameObjects & components | verify | state verification |
| Create/modify GameObjects, scenes | bootstrap, feature | safe scene edits |
| Execute Editor menu items / C# in Editor | bootstrap | fallback for anything else |

At session start (bootstrap/verify), discover what the connected server
actually exposes by listing its tools — tool names differ per implementation
(e.g. `read_console` vs `console_logs`). Match by capability, not by name.

## 2. Known implementations (verify before recommending — this ecosystem moves fast)

- **CoplayDev/unity-mcp** — widely used community server; Python bridge + Unity package.
- **CoderGamester/mcp-unity** — Node-based, broad Editor coverage.
- **IvanMurzak/Unity-MCP** — C#-centric with reflection-based Editor access.

When guiding installation: point the user to the repo's own README (install
steps change), confirm the Unity package side is imported AND the server side
is registered in Claude Code (`claude mcp list` should show it), then verify
round-trip by reading the Unity console.

## 3. Graceful degradation — the manual verification protocol

Without MCP, `verify` must NOT silently skip steps. It switches to guided
manual mode and reports each step as `MANUAL_REQUIRED`:

| Automated step | Manual fallback (give the user these exact instructions) |
|---|---|
| Compile check | "Focus the Unity window (triggers recompile). Report any red errors in the Console." |
| Console errors | "Console → Clear, then reproduce. Paste anything red." |
| EditMode tests | "Window → General → Test Runner → EditMode → Run All. Paste the summary line." |
| PlayMode tests | "Test Runner → PlayMode → Run All. Paste the summary line." |
| Scene runtime check | "Open Assets/_Game/Scenes/Gameplay/FirstPlayable.unity, press Play, and check: <list the spec's runtime checks>." |

The verification report then records these as `VERIFIED (user-reported)` —
distinct from tool-verified — or `UNVERIFIED` if the user skipped them.

An alternative automated fallback when the Editor can be closed: Unity CLI
batch mode test runs (see `unity-testing.md` §2). Offer it, don't force it.

## 4. Scene-edit fallback without MCP

For bootstrap/feature scene work without MCP, generate a **one-shot Editor
script** under `Assets/_Game/Scripts/Editor/` exposing a menu item
(`[MenuItem("FirstPlayable/Setup Scenes")]`) that does the work through the
Unity API, tell the user to click it, then verify results by reading the
created files' existence (not their YAML content). Delete or keep the script
per user preference; record either way in `Docs/PROJECT_STATUS.md`.
