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

> **`runInBackground` must be ON for any runtime observation.** An
> agent-driven Editor is never the foreground window, and an unfocused Editor
> does not advance frames in play mode. With it off, `Time.frameCount` stays
> frozen and every runtime measurement silently reports stale state — the
> failure mode is a confident, wrong `VERIFIED`. Bootstrap sets this; verify
> should confirm frames advance before trusting any sample.

## 2. The official path first: Unity MCP Server (Unity 6)

Unity 6 ships an official MCP server via the AI Assistant package. **Recommend
this before any community implementation** — it is signed, project-aware, and
has a built-in client approval flow. Setup:

1. Package Manager (`Window → Package Management → Package Manager` in Unity
   6.5+; `Window → Package Manager` in earlier versions) → `[+]` →
   **Install package by name…** → `com.unity.ai.assistant`
2. `Edit → Project Settings → AI → Unity MCP Server` → **Start**
   (Status: Running). Note the useful toggles on this page: Validation Level,
   Auto-approve in Batch Mode, and the per-tool enable list (Tools section).
3. Launch `claude` in the project folder → `claude-code` appears under
   **Connected Clients** → the user approves it once (shows **Accepted**).

Its tools are typically named `Unity_*` (e.g. `Unity_RunCommand`,
`Unity_GetConsoleLogs`). `Unity_RunCommand` compiles and executes C# in the
Editor — one capability that covers scene edits, settings, and most Editor
automation. Caveats: script classes must be `internal class CommandScript :
IRunCommand`, and some namespaces (e.g. `System.Reflection` imports) are
blocked by its validator. Only a subset of tools may be enabled — check the
Tools list in the settings page rather than assuming.

## 3. Community implementations (alternatives — verify before recommending)

- **CoplayDev/unity-mcp** — widely used community server; Python bridge + Unity package.
- **CoderGamester/mcp-unity** — Node-based, broad Editor coverage.
- **IvanMurzak/Unity-MCP** — C#-centric with reflection-based Editor access.

When guiding installation: point the user to the repo's own README (install
steps change), confirm the Unity package side is imported AND the server side
is registered in Claude Code (`claude mcp list` should show it), then verify
round-trip by reading the Unity console.

## 4. Retry protocol — reload and compile gaps are normal

Editing scripts triggers a domain reload; the bridge goes silent for 20–60s.
These responses are **not failures** and must not be reported as such:

| Response | Meaning | Action |
|---|---|---|
| `Unity not detected` / no discovery file | domain reload in progress | wait 30–45s, retry once or twice |
| `COMPILATION_IN_PROGRESS` | compiling | same — **but if play mode is running, suspect the deadlock** |

The second row is the important one. In play mode Unity *defers* compilation,
so `COMPILATION_IN_PROGRESS` never resolves on its own — waiting longer makes
it worse. If two retries pass with no progress, stop retrying and tell the user
to press **Stop** in the Editor; that is the only exit.

## 5. Editor APIs that do not work over MCP

Anything that opens a modal dialog fails with *"User interactions are not
supported for MCP tool calls"* — `AssetDatabase.DeleteAsset` (confirmation
prompt), `EditorUtility.DisplayDialog`, `AssetDatabase.ImportPackage(...,
interactive: true)`, and friends. Use non-interactive overloads, or fall back
to file-system operations plus `AssetDatabase.Refresh()`.

If the connected server validates the C# it executes, expect extra
restrictions: a required class name/shape, and a namespace allowlist that can
reject things like `System.Reflection`. Read the error and adapt rather than
retrying the same shape.

When capturing screenshots of the Editor for evidence, **read the image back
and confirm it shows Unity** — if the Editor is not the foreground window, the
capture silently grabs whatever is. A wrong screenshot in a verification
report is worse than no screenshot.

## 6. Graceful degradation — the manual verification protocol

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

## 7. Scene-edit fallback without MCP

For bootstrap/feature scene work without MCP, generate a **one-shot Editor
script** under `Assets/_Game/Scripts/Editor/` exposing a menu item
(`[MenuItem("FirstPlayable/Setup Scenes")]`) that does the work through the
Unity API, tell the user to click it, then verify results by reading the
created files' existence (not their YAML content). Delete or keep the script
per user preference; record either way in `Docs/PROJECT_STATUS.md`.
