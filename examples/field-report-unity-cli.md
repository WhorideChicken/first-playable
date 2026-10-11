# Field Report — Adopting the Unity CLI

*What happened when FirstPlayable's verify loop was moved onto the Unity CLI.*

Source material for **v0.4.0**. Same project as the
[first field report](field-report-unity-6.md)
([MousePotatoGames/RBB-public](https://github.com/MousePotatoGames/RBB-public)),
Windows 11, Unity 6000.5.6f1, CLI `1.0.0-beta.13`, `com.unity.pipeline`
`0.8.0-exp.1`. Everything below was observed, including the agent's own mistake.

## Verdict

**No overhaul.** The workflow — design, scope, specs, evidence labels, rule IDs —
doesn't care how the agent reaches the Editor. The CLI is a second transport
with real advantages for verification, and it is beta software on an
experimental package. It sits next to MCP; it does not replace it.

## Incidents

| # | What happened | Changed |
|---|---|---|
| U1 | Not signed in: headless `unity test` exited `6` (`EDITOR_LICENSING_FAILURE`) after ~1s | sign-in is preflight #1 |
| U2 | Not signed in: `unity open` stalled at Hub *"Signing in…"*; `unity status` said "no instances" for 6+ minutes, no error | same; documented as silence, not failure |
| U3 | `pipeline list` said `isRunning: true` with no Editor open; the CLI's auth broker is a process named `unity` | never detect the Editor by process name |
| U4 | `editor_play` returned before `EnteredPlayMode` fired — the guard marker was missing for several seconds | marker written on `ExitingEditMode` |
| U5 | Starting a PlayMode test run removed the marker right after it was written | marker re-creates itself while playing |
| U6 | **The agent deadlocked the Editor** by patching a script via `python` during a PlayMode run | rule covers every write path; hook limitation documented |
| U7 | Errors logged mid-reload were gone from the Editor console but kept in the CLI buffer | verify reads the buffer |
| U8 | PowerShell 5.1 split quoted C# passed to `eval` | use `eval_file --file` |

## The big one: the deadlock has an exit now

v0.3.0's worst incident (A1) was a deadlock only a human could break: edit a
script during play mode, Unity defers the compile, MCP refuses every command.
Reproduced deliberately over the CLI:

- In `playing + compiling=true`, the CLI **kept answering** `editor_status`.
- `editor_stop` exited play mode; the compile completed ~10s later.
- Unity logged two internal lifecycle errors at that instant, then recovered.

Then it happened for real (U6): the agent edited a file during a PlayMode test
run — from a shell, so the guard hook never saw it. The run hung. `cancel_tests`
ended it cleanly. A rule the agent had just written into this plugin was broken
by the agent an hour later, which is the argument for the rule and for the exit.

## The other big one: test verdicts became mechanical

| `unity test` exit | Meaning | Label |
|---:|---|---|
| `0` | passed | `VERIFIED` |
| `8` | ran, failed | `VERIFIED` (failing) |
| `6` | no verdict | `UNVERIFIED` |

U1 was a `6` and correctly not a failure. After sign-in: **218 EditMode tests,
exit 0, 113s**, JUnit names intact (`Move001_DiagonalInput_IsNormalized`), so
rule-ID traceability survives into CI. Live in the open Editor:
**133 PlayMode tests** via `run_tests` + `test_status`, ~73s.

## Also confirmed

- `editor_status` reports `playMode`, `compiling`, `domainReloadInProgress`
  directly, which settles the ambiguity behind v0.3.0's A3.
- `delete_asset --confirm true` worked with no dialog, unlike the MCP case (D2).
- With `runInBackground` on, frames advanced while unfocused (1 → 1263 in ~3s).
  The v0.3.0 rule (A2) still matters.
- A command sent right after `editor_play` failed with *"Connection reset by
  server"* and worked on retry. Reload gaps happen here too.

## Not tested

`simulate_key` / `simulate_pointer` (input during instrumentation, which is what
v0.3.0's B1 needed), `capture_game_view`, `set_autotick`. They're listed by the
Editor but haven't been exercised, so this plugin doesn't recommend them yet.
