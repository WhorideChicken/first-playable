# Unity CLI Reference

The Unity CLI (`unity`) is a second way for the agent to reach the Editor,
alongside Unity MCP. Read this when `unity --version` succeeds on the machine.
Everything here was observed on a real project (Windows, Unity 6000.5.6f1,
CLI `1.0.0-beta.13`, `com.unity.pipeline` `0.8.0-exp.1`) — see
[examples/field-report-unity-cli.md](../examples/field-report-unity-cli.md).

> **Status: beta CLI + experimental package.** Treat it as an option that is
> better than MCP for specific jobs, not as a replacement. MCP stays supported.

## 1. Two modes, two prerequisites

| Mode | What it is | Needs |
|---|---|---|
| **Headless** — `unity test`, `unity build` | spawns a batch Editor, runs, exits | Editor **closed** for that project; CLI **signed in** |
| **Live** — `unity status`, `unity command <tool>` | drives the open Editor | `com.unity.pipeline` in the project (`unity pipeline install`); CLI **signed in** |

**Sign-in is the first preflight, not an afterthought.** Without it:

- `unity test` exits `6` with `EDITOR_LICENSING_FAILURE` about a second after
  starting — no tests run.
- `unity open` hands off to Unity Hub, which sits on *"Signing in…"*. The Editor
  never launches, and `unity status` keeps returning `STATUS_NO_INSTANCES` —
  indefinitely, with no other error. Silence, not failure.

Check with `unity auth status --json` (`data.loggedIn`) and
`unity license status --json` (`data.active`). Sign-in is browser OAuth — the
**user** runs `unity auth login`; the agent must not attempt it.

`unity pipeline install` edits `Packages/manifest.json` and
`packages-lock.json`. That is a project change: show it, and let the user
decide whether to commit it.

## 2. Is the Editor actually there?

- Trust `unity status --json` → `data.instances[].state == "ready"`. It became
  ready ~24s after launch on a warm project.
- **Do not detect the Editor by process name.** The CLI's own auth broker runs
  as a process named `unity`, and `unity pipeline list` reported
  `isRunning: true` while no Editor was open.
- `unity command editor_status` gives ground truth in one call: `playMode`,
  `compiling`, `domainReloadInProgress`. Prefer it over inferring state from
  silence.

## 3. Tests — the exit codes map onto evidence labels

```bash
unity test <project> --mode EditMode --report-format junit --output results.xml --timeout 600
```

| Exit | Meaning | Evidence label |
|---:|---|---|
| `0` | ran, all passed | `VERIFIED` (for what those tests assert) |
| `8` | ran, some **failed** | `VERIFIED` — failing. Report the names; never retry to make it green |
| `6` | never produced a verdict (license, compile error, crash, timeout) | `UNVERIFIED` + the `errors[0].code` |

JUnit output carries the test names, so rule-ID naming (`Move001_...`) survives
into the report. Headless needs the Editor closed; with the Editor open, use the
live path instead:

```bash
unity command run_tests --mode playmode --async_tests true   # returns immediately
unity command test_status                                     # poll once per few seconds
```

## 4. The play-mode deadlock has an exit here

Over MCP, editing a script during play mode locks everything until a human
presses Stop (v0.3.0, A1). Over the CLI, reproduced deliberately:

- `playMode=playing, compiling=true` — the deadlock state — and the CLI **still
  answered** `editor_status` and `recompile_status`.
- `unity command editor_stop` exited play mode; the deferred compile finished
  ~10s later.
- **Cost:** Unity logged two internal errors at that instant (*"Tried to enter
  EditModeScope while already in EditModeScope"*). The Editor recovered
  normally.

**During a test run, use `cancel_tests` instead.** This was not a staged test:
the agent patched a script from a shell while `run_tests` was running (PlayMode
tests *are* play mode, and the shell write bypassed the guard hook). The run hung
at `running` with `playing + compiling=true`. `cancel_tests` alone ended the
run, the test runner left play mode, and the compile completed;
`editor_stop` then reported "Already in edit mode".

So: these are **emergency exits**, not permission. The rule "never edit code
while play mode runs" stands. When you use one, note the lifecycle errors in the
verification report as caused by the recovery, not by the feature.

**Right after `editor_play`, expect one dropped call.** Entering play mode
reloads the domain; an `editor_stop` sent immediately failed with
*"Connection reset by server"* and succeeded on the first retry. Same rule as
the reload gaps in `references/unity-mcp.md` §4 — retry, don't report failure.

**The guard marker needed two fixes found here**
(`templates/unity/PlayModeMarker.cs`): `editor_play` returned seconds before
`EnteredPlayMode` fired, so the marker is now written on `ExitingEditMode`; and
starting a PlayMode test run removed the marker right after it was written
(deleter not identified), so it now re-creates itself every editor tick while
playing. Verified present for a whole 133-test PlayMode run.

## 5. Console: read the CLI buffer, not just the Editor's counts

`unity command console_status` returns both a buffer (`counts`) and
`groundTruth` (the Editor console right now). After a recompile, the Editor
console had been cleared — `groundTruth.consoleErrors: 0` — while the CLI buffer
still held the errors logged during the reload. For "no **new** errors", read
`unity command console --level error`; checking the Editor's current count can
hide errors that happened mid-reload.

## 6. Tools that retire v0.3.0 workarounds

| v0.3.0 problem | CLI tool | Observed |
|---|---|---|
| A3 — silence during reload is ambiguous | `editor_status`, `recompile_status` (`idle\|triggered\|compiling\|completed`) | explicit state; still briefly empty mid-reload, so keep the retry rule |
| D1 — polling a result file | `run_tests --async_tests true` + `test_status` | 133 PlayMode tests, `completed` with a summary in ~73s. The status file `Temp/pipeline_test_status.json` is *absent* mid-run — read `test_status`, not the file |
| D2 — `DeleteAsset` dialog fails | `delete_asset --asset <path> --confirm true` | deleted asset + `.meta`, no dialog; refuses without `--confirm` |

Discover the rest with `unity list --json` (160 tools on this Editor). Names are
defined by the package version — list them, don't assume.

## 7. Windows PowerShell 5.1: pass C# through a file

PowerShell 5.1 splits quoted arguments to native commands, so
`unity command eval 'return "a" + b;'` fails with `INVALID_COMMAND_ARGS`
("takes 2 positional values but got 3"). Single-token expressions work; for
anything with quotes or spaces, write the code to a file and use
`unity command eval_file --file <path>` (the parameter is `--file`, not `--path`).

## 8. New projects are not our job

Creating a brand-new project (Editor install, template, VCS) is covered by
Unity's own `new-unity-project` / `unity-cli` agent skills. FirstPlayable's
`bootstrap` starts from an existing project and makes it workflow-ready.
