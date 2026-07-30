# Changelog

All notable changes to FirstPlayable are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [SemVer](https://semver.org/) (0.x may break between minors).

## [Unreleased]

### Planned
- v0.2: bootstrap preflight hardening, risk-detection hooks
- v0.3: feature/verify end-to-end validation against a real Unity 6 project
- v0.4: playtest → spec feedback loop refinement
- v1.0: primitive-only example project, Windows/macOS validation, release automation

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
