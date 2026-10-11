# Examples

## Field report — Unity 6 (available now)

**[field-report-unity-6.md](field-report-unity-6.md)** — what broke when this
workflow met a real Unity 6.5 project across features F01–F07, and what changed
in v0.3.0 as a result. Eight incidents, all of which actually happened; six of
them produced *passing checks with wrong conclusions* rather than crashes.

Useful if you want to know what this workflow is actually defending against
before adopting it.

The project it came from is public too:
[MousePotatoGames/RBB-public](https://github.com/MousePotatoGames/RBB-public) —
including the [original operations log](https://github.com/MousePotatoGames/RBB-public/blob/main/Docs/Process/WORKFLOW_PITFALLS.md)
(Korean) and the `Docs/` tree this workflow generates in practice
(game design, feature specs, verification reports, playtest records).

## Field report — Unity CLI (v0.4.0)

**[field-report-unity-cli.md](field-report-unity-cli.md)** — moving the verify
loop onto the Unity CLI: sign-in traps, a guard marker that two Unity behaviors
defeated, an exit from v0.3.0's play-mode deadlock, and the agent breaking its
own rule an hour after writing it.

## Reference project

There is no toy sample. The example is a real game built with this workflow:
**[MousePotatoGames/RBB-public](https://github.com/MousePotatoGames/RBB-public)**.
Look at its `Docs/` tree for what the workflow actually produces: design docs
with rule IDs, Feature Specs, verification reports that separate `VERIFIED` from
`INFERRED`, and playtest records. A primitive-shapes demo was planned and
dropped. It would have shown less than a real project and still needed
maintaining.
