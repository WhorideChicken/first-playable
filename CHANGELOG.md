# Changelog

All notable changes to FirstPlayable are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [SemVer](https://semver.org/) (0.x may break between minors).

## [Unreleased]

### Planned
- v0.5: playtest → spec feedback loop refinement
- v1.0: primitive-only example project, Windows/macOS validation, release automation

## [0.4.1] - 2026-10-12

The three Unity CLI tools v0.4.0 left untested, now run on the same project.

### Added
- `verify`: over the CLI, hold real input during instrumentation with
  `simulate_key` (closes v0.3.0's B1), and confirm it landed by its effect.
  Reading the input action back via `eval` returned `(0, 0)` while the key was
  driving the ball
- `references/unity-cli.md` §6: `simulate_key`, `set_autotick`,
  `capture_game_view` results and traps. Auto-tick is on by default and masks
  `runInBackground = false`, but once frames stop, re-enabling it doesn't
  recover them, so the A2 rule stands. `capture_game_view --save_path` writes
  under `Assets/`

## [0.4.0] - 2026-10-11

Unity CLI support, validated on the same Unity 6 project as v0.3.0. Not an
overhaul: the CLI is a second transport next to MCP. Every item below was
observed — see `examples/field-report-unity-cli.md`.

### Added
- `references/unity-cli.md`: headless vs live modes, sign-in as preflight #1,
  test exit codes mapped to evidence labels (`0` / `8` failing / `6` no verdict),
  the play-mode deadlock exits (`editor_stop`, `cancel_tests` during test runs),
  console-buffer vs Editor-count, PowerShell 5.1 quoting, tools that retire
  v0.3.0 workarounds
- `examples/field-report-unity-cli.md`

### Changed
- `PlayModeMarker.cs`: write on `ExitingEditMode` (an agent's `editor_play`
  returned before `EnteredPlayMode` fired), and re-create the marker every tick
  while playing (a PlayMode test run start removed it). Verified for a full
  133-test run. **Re-copy it into existing projects.**
- `verify`: PlayMode test runs count as play mode; the no-edit rule covers every
  write path, not just the tools the hook sees; read the CLI console buffer for
  new errors; `unity test` exit codes as verdicts
- `bootstrap`: CLI preflight (installed / signed in / pipeline package); brand-new
  projects hand off to Unity's own `new-unity-project` skill
- `unity-guard`: message names the CLI escape
- `hooks/README.md`: play-mode row added; documents that shell writes bypass the hook
- `references/unity-testing.md`: raw `-batchmode -runTests` replaced by `unity test`

## [0.3.1] - 2026-08-01

### Added
- Field report now links to its source: the original operations log in
  [MousePotatoGames/RBB-public](https://github.com/MousePotatoGames/RBB-public),
  a public Unity 6 project built with this workflow
- `CONTRIBUTING.md`: release rule — bump the version for *any* content change,
  since `claude plugin update` compares versions, not commits (a docs-only push
  under the same version leaves installed users on a stale copy)

## [0.3.0] - 2026-08-01

Hardening pass driven by a real Unity 6 project run through F01–F07. Every
change below traces to an incident that actually happened, not a hypothetical.

### Added
- **`examples/field-report-unity-6.md`** — the incidents behind this release,
  published in full: what broke, what it cost, and what each one changed
- `templates/unity/Game.Editor.asmdef` (the architecture referenced it; the
  template was missing)
- **Play-mode deadlock guard** (`templates/unity/PlayModeMarker.cs` +
  `unity-guard` hook): editing a script during play mode defers recompilation,
  which locks the MCP bridge with no way to exit play mode — only a human
  pressing Stop breaks it. The marker file lets the hook refuse the edit first.
- **`runInBackground` blocking preflight** in `bootstrap`: an unfocused Editor
  does not advance frames, so runtime observations silently report stale state.
  This produced a wrong `VERIFIED` that had to be retracted.
- **MCP retry protocol** in `references/unity-mcp.md`: `Unity not detected` /
  `COMPILATION_IN_PROGRESS` are normal during reloads — but never resolve in
  play mode, where they signal the deadlock above.
- **Non-interactive Editor API list** and screenshot-verification rule in
  `references/unity-mcp.md`.

### Changed
- `verify`: runtime measurements must state their conditions; measurements
  taken without continuous input are `INFERRED`, not `VERIFIED`. **Negative
  conclusions ("X never triggers") can never be `VERIFIED` by instrumentation**
  — indistinguishable from failing to create the trigger conditions.
- `verify`: warning review promoted from optional to mandatory; UI text
  requires a clean console plus a visual check, because string assertions pass
  while glyphs render as boxes.
- `verify`: exit gate — diagnostic values must be restored and read back before
  the report is written; unrestored items go at the top as `⚠ NOT RESTORED`.
- `verify`: never edit code while play mode runs (exit → edit → re-enter).
- `references/unity-testing.md`: transient state (hit-stop, cooldowns,
  invulnerability) must assert it *happened* via a counter before asserting it
  ended — end-state-only assertions pass vacuously.
- `references/unity-testing.md`: match rules to tests by assertion content, not
  test name; added a result-wait protocol to stop polling round-trips.
- `feature`: explicit wiring order (compile → wire → save → read back), and
  scene-wiring scripts must ship a `Verify()` — recompilation nulls inspector
  references.
- `playtest`: experiment definitions must include how to undo diagnostic values.
- `unity-qa` agent: audits whether a test would actually fail if its rule broke.

## [0.2.1] - 2026-07-30

### Added
- README rewritten as a friendly step-by-step guide: quick start, Unity-side
  MCP setup (`com.unity.ai.assistant` → Project Settings → AI → Unity MCP
  Server), update instructions with the full-name gotcha, troubleshooting
- Setup GIF captured from a real Unity 6.5 editor (`docs/media/unity-mcp-setup.gif`)
- `references/unity-mcp.md`: official Unity MCP Server documented as the
  primary path, including `Unity_RunCommand` caveats (CommandScript class
  name, blocked namespaces, per-tool enable list)

## [0.2.0] - 2026-07-30

### Added
- `unity-guard` PreToolUse hook: asks for confirmation before direct Unity
  YAML edits, `Assets/ThirdParty` modifications, and `.meta` writes/deletions
  (fail-open by design)
- `references/unity-setup.md`: editor settings, git config, asmdef
  architecture with dependency rules, package guidance, scene-creation
  fallbacks, bootstrap idempotency checklist
- `references/unity-testing.md`: humble-object pattern for engine-free rule
  testing, EditMode/PlayMode patterns, PlayMode pitfall table, spec↔test
  coverage contract
- `references/unity-mcp.md`: capability-based MCP discovery, known
  implementations, manual verification protocol for MCP-less setups
- `references/game-feel.md`: complaint → candidate-parameter diagnosis tables
  (movement, camera, feedback, difficulty) with starting value ranges
- `templates/unity/`: six ready-made asmdef files (including engine-free
  `Game.Core`), Unity `.gitignore`, `PROJECT_STATUS.md` template

### Changed
- `bootstrap`, `feature`, `verify`, `playtest` skills now delegate deep
  guidance to the new reference docs (progressive disclosure — skill bodies
  stay small)

## [0.1.0] - 2026-07-30

### Added
- Plugin structure (`.claude-plugin/plugin.json`, marketplace manifest)
- Skills: `design`, `review-design`, `scope`, `bootstrap`, `feature`, `verify`, `playtest`
- Agents: `game-designer`, `unity-architect` (read-only), `unity-qa` (read-only)
- Document templates: game design set, First Playable set, feature spec,
  decision record, verification & playtest reports, project `CLAUDE.md`
- Status taxonomy (CONFIRMED/PROPOSED/TEMPORARY/UNRESOLVED/EXCLUDED) and
  evidence taxonomy (VERIFIED/INFERRED/UNVERIFIED/MANUAL_REQUIRED)

### Notes
- v0.1 focuses on the design workflow. `bootstrap`, `feature`, `verify`, and
  `playtest` skills ship as specifications and will be hardened against real
  Unity 6 projects in v0.2–v0.4.
