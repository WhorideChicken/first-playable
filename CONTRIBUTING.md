# Contributing to FirstPlayable

Thanks for your interest! FirstPlayable is early-stage, so the most valuable
contributions right now are **real-world usage reports**.

## Ways to help

1. **Use it and report.** Run the workflow on an actual game idea (or an actual
   jam) and open an issue describing where it helped and where it got in the
   way. Include which skill, what you expected, what happened.
2. **Improve the skills.** Skills live in `skills/*/SKILL.md` as plain
   Markdown. PRs that make instructions clearer, shorter, or safer are welcome.
3. **Templates.** Better default templates in `templates/` — especially ones
   proven in real projects.
4. **Unity coverage.** Testing bootstrap/verify against different Unity 6
   setups (URP/HDRP/Built-in, different MCP servers) and documenting results.

## Ground rules

- Keep the core philosophy: playable-first, labeled decisions, labeled
  evidence, smallest scope that proves the fun.
- Skills must stay safe by default: dry-run before writes, no direct Unity
  YAML edits, no touching `Assets/ThirdParty`.
- English for skills/templates/README (the plugin ships worldwide); issues and
  discussions in English or Korean are both fine.
- One focused change per PR. PRs are squash-merged.

## Repository layout

```text
.claude-plugin/   plugin + marketplace manifests
skills/           one directory per skill (SKILL.md)
agents/           subagent definitions
templates/        document templates the skills copy from
hooks/            risk-detection hooks (planned, v0.2)
examples/         primitive-only example project (planned, v1.0)
docs/             project plan and design notes
```

## Do not include

- Unity Asset Store content or any asset you can't redistribute under MIT
- API keys, tokens, MCP credentials, personal paths
- Copies of other plugins' source
- Unity `Library/`, `Temp/`, `Logs/`, `Obj/`, build outputs
