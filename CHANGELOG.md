# Changelog

All notable changes to FirstPlayable are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [SemVer](https://semver.org/) (0.x may break between minors).

## [Unreleased]

### Planned
- v0.3: feature/verify end-to-end validation against a real Unity 6 project
- v0.4: playtest → spec feedback loop refinement
- v1.0: primitive-only example project, Windows/macOS validation, release automation

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
