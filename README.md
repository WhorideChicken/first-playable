# FirstPlayable

**An AI-assisted workflow that turns game ideas into tested, playable Unity builds.**

[![Version](https://img.shields.io/badge/version-0.4.3-blue)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-plugin-8A63D2)](https://claude.com/claude-code)

FirstPlayable is a [Claude Code](https://claude.com/claude-code) plugin for solo
developers, small teams, and game jammers, built around one idea:

> **A feature is not done when the code compiles.
> It is done when you can actually play it.**

AI coding tools are great at producing code that *looks* finished. FirstPlayable
adds the missing structure: your decisions get written down before
implementation, the AI's suggestions never silently become your decisions, and
nothing counts as "done" until it survived compilation, tests, a real scene
run — and your own hands on the keyboard.

> 🇰🇷 한국어 기획 문서는 [docs/PROJECT_PLAN.ko.md](docs/PROJECT_PLAN.ko.md)에 있습니다.

---

## Table of contents

- [How it works](#how-it-works)
- [Quick start](#quick-start)
  - [1. Install the plugin](#1-install-the-plugin)
  - [2. Connect Unity (optional, needed from Phase 4)](#2-connect-unity-optional-needed-from-phase-4)
  - [3. Start designing](#3-start-designing)
- [Keeping it updated](#keeping-it-updated)
- [The seven skills](#the-seven-skills)
- [Core principles](#core-principles)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)

---

## How it works

```mermaid
flowchart TD
    A["1 · Design interview"] --> B["2 · Design review"]
    B --> C["3 · First Playable scope"]
    C --> D["4 · Unity bootstrap"]
    D --> E["5 · Feature spec"]
    E --> F["6 · Implement & verify"]
    F --> G["7 · Play it yourself"]
    G --> H["Structured feedback"]
    H --> E
```

Each phase produces documents that the next phase treats as the source of
truth — so the AI implements what **you** decided, not what it guessed. Phases
1–3 are pure conversation and work anywhere. Phases 4–7 connect to a real
Unity project.

---

## Quick start

### What you need

| Requirement | Needed for | Notes |
|---|---|---|
| [Claude Code](https://claude.com/claude-code) | everything | CLI, desktop app, or IDE extension |
| Unity 6 | Phases 4–7 | design phases (1–3) work without Unity |
| Unity CLI **or** Unity MCP | Phases 4–7 | how the agent reaches the Editor — [setup below](#2-connect-unity-optional-needed-from-phase-4). Optional: without either, `verify` walks you through it manually |

### 1. Install the plugin

Run these two commands in any terminal:

```bash
claude plugin marketplace add WhorideChicken/first-playable
```

```bash
claude plugin install first-playable
```

**Check it worked:** run `claude plugin list` — you should see
`first-playable@first-playable · enabled`. Then open `claude` in any folder and
type `/first-playable` — seven skills should autocomplete.

This is a **user-level install**: it works in every project on your machine,
for your OS user account. No per-project setup needed.

### 2. Connect Unity (optional, needed from Phase 4)

There are two ways for the agent to reach the Unity Editor. Use either one, or
both — they coexist, and nothing in the workflow requires a particular one.

| | **A. Unity CLI** *(beta)* | **B. Unity MCP** |
|---|---|---|
| Test results | the exit code *is* the verdict: `0` passed, `8` ran and failed, `6` no verdict | read back from the Editor |
| Stuck in play mode with a pending recompile | `editor_stop` / `cancel_tests` gets out | only a human pressing Stop |
| Runtime checks | `simulate_key` holds real input (not press edges — see [unity-cli.md](references/unity-cli.md) §6); `capture_game_view` grabs the game incl. overlay UI, even with Unity minimized | via the Editor tools you enable |
| Maturity | CLI `1.0.0-beta` + experimental `com.unity.pipeline` | official AI Assistant package (pre-release) |

**Recommendation:** use the CLI for verification — every advantage above was
confirmed on a real project ([field report](examples/field-report-unity-cli.md)).
Keep MCP if you already have it.

#### A. Unity CLI

![Unity CLI setup: version check, sign-in, pipeline install, live Editor ready with 160 tools, then a headless EditMode run that exits 0 with 218 tests passed](docs/media/unity-cli-setup.gif)

*Real output from this project — not mocked.*

1. **Install the CLI** (then open a new terminal so `unity` is on PATH)

   ```powershell
   $env:UNITY_CLI_CHANNEL='beta'; irm https://public-cdn.cloud.unity3d.com/hub/prod/cli/install.ps1 | iex
   ```

   ```bash
   curl -fsSL https://public-cdn.cloud.unity3d.com/hub/prod/cli/install.sh | UNITY_CLI_CHANNEL=beta bash
   ```

2. **Sign in — don't skip this.** Signed out, headless tests die on licensing
   in about a second, and `unity open` waits silently at Hub's sign-in screen.

   ```bash
   unity auth login
   ```

3. **Add the Pipeline package** — run inside your Unity project. It edits
   `Packages/manifest.json`; commit it if you keep it.

   ```bash
   unity pipeline install
   ```

4. **Open the Editor** (`unity open .` or from Hub) and check it's reachable:
   `unity status` should say **ready**. Headless runs (`unity test`) need the
   Editor *closed* for that project; with it open, the agent uses the live
   Editor instead.

Details and every trap we hit: [references/unity-cli.md](references/unity-cli.md).

#### B. Unity MCP

Unity 6 ships an official MCP server in the AI Assistant package. Three steps,
all inside the Unity Editor:

![Unity MCP setup: install com.unity.ai.assistant, open Project Settings > AI > Unity MCP Server, start the server and see claude-code connected](docs/media/unity-mcp-setup.gif)

1. **Install the Assistant package**
   `Window → Package Management → Package Manager` → click **`[+]`** (top-left) →
   **Install package by name…** → enter:

   ```text
   com.unity.ai.assistant
   ```

2. **Start the MCP server**
   `Edit → Project Settings → AI → Unity MCP Server` → press **Start**.
   Status should show a green **Running**.

3. **Connect Claude Code**
   Run `claude` in your Unity project folder. Within a few seconds,
   `claude-code` appears under **Connected Clients** — approve it once and
   it shows as **Accepted**. Done.

> **Neither? You can still use everything.** The `verify` skill switches to a
> guided manual protocol (it tells you exactly what to click in Unity and
> records your answers), and `bootstrap` generates one-shot Editor scripts
> instead of editing scenes directly. Community MCP servers also work — see
> [references/unity-mcp.md](references/unity-mcp.md).

### 3. Start designing

Open `claude` anywhere and describe your game:

```text
/first-playable:design
```

The AI interviews you (3–5 questions at a time), writes your answers into
design documents, and labels every statement as **your decision** or **its
suggestion**. From there, each phase tells you what command comes next.

---

## Keeping it updated

When a new version is released, run:

```bash
claude plugin marketplace update first-playable
```

```bash
claude plugin update first-playable@first-playable
```

> ⚠️ Two things people hit:
> - The update command needs the **full name** `first-playable@first-playable`
>   (plugin name @ marketplace name). The short name will say "not found".
> - **Restart any open Claude Code sessions** after updating — running
>   sessions keep the old version until restarted.

---

## The seven skills

| Command | What it does | You get |
|---|---|---|
| `/first-playable:design` | Interviews you about your game idea, 3–5 questions at a time | `Docs/Game/` — overview, core loop, rules with IDs, glossary |
| `/first-playable:review-design` | Hunts contradictions, missing decisions, scope creep — **before** any code | `DESIGN_REVIEW.md` with an explicit approval gate |
| `/first-playable:scope` | Cuts the game down to the smallest build that proves the fun | `FIRST_PLAYABLE.md`, dev order, falsifiable playtest hypotheses |
| `/first-playable:bootstrap` | Sets up folders, scenes, asmdefs, project rules — **always dry-runs first** | a safe, idempotent Unity project skeleton + `CLAUDE.md` |
| `/first-playable:feature <name>` | Writes a spec, waits for your approval, then implements with tests | `Docs/Features/<name>.md`, pure-logic code, EditMode/PlayMode tests |
| `/first-playable:verify <name>` | Compile → console → tests → real scene run, honestly labeled | a verification report separating facts from judgment calls |
| `/first-playable:playtest` | Turns "it feels slippery" into hypotheses and a one-variable experiment | `Docs/Playtests/` records that feed back into specs |

Behind the skills: three agents (`game-designer`, plus read-only
`unity-architect` and `unity-qa` reviewers), deep-dive reference docs
([Unity setup](references/unity-setup.md) ·
[testing](references/unity-testing.md) ·
[MCP](references/unity-mcp.md) ·
[game feel](references/game-feel.md)), and ready-made
[templates](templates/) including six asmdefs with an engine-free `Game.Core`.

### The safety hook

Installing the plugin also activates `unity-guard`, which catches four
classic AI-assisted-Unity accidents **before they happen** and asks you first:

- **editing a script while Unity is in play mode** — this deadlocks the whole
  session (Unity defers the recompile, MCP locks up, and nothing can exit play
  mode but your own hand on the Stop button)
- editing `.unity` / `.prefab` / `.asset` files as raw text (corrupts scenes)
- modifying anything under `Assets/ThirdParty` (lost on update, license risk)
- writing or deleting `.meta` files (silently breaks asset references)

It's ask-not-block (you can always override) and stays silent outside Unity
projects, so it won't bother your other work.

---

## Core principles

**Decisions are labeled.** Every statement in every document carries a status:

| Label | Meaning |
|---|---|
| `CONFIRMED` | you decided this |
| `PROPOSED` | the AI suggested it — not yet your decision |
| `TEMPORARY` | placeholder value, good enough for a prototype |
| `UNRESOLVED` | needs a decision before implementation |
| `EXCLUDED` | explicitly decided NOT to build |

**Evidence is labeled.** Verification reports distinguish `VERIFIED` (actually
ran it) from `INFERRED` (read the code) from `MANUAL_REQUIRED` (only a human
playing can judge). The AI never gets to claim game feel works.

**Everything traces.** Rule ID → feature spec → test name → verification
report → playtest record. When a rule changes, you can see exactly which
features and tests are affected.

**Safe by default.** Approval gates before implementation, dry-runs before
writes, the unity-guard hook, and no direct Unity YAML edits — ever.

### Why these rules exist

They aren't theoretical. v0.3.0 was written from a real Unity 6 project run,
where six of eight incidents were *passing checks with wrong conclusions* —
including one measurement that concluded the exact opposite of what a human
found in 30 seconds of play.

📋 **[Read the field report](examples/field-report-unity-6.md)** · and the
**[Unity CLI follow-up](examples/field-report-unity-cli.md)**, where the agent
broke its own play-mode rule an hour after writing it — the
incidents, the costs, and what each one changed.

---

## Troubleshooting

<details>
<summary><code>claude plugin list</code> shows nothing after installing</summary>

The output can be long — scroll: your plugin is likely there. If genuinely
missing, re-run the install and check `~/.claude/settings.json` contains
`"first-playable@first-playable": true` under `enabledPlugins`.
</details>

<details>
<summary>Installed version is older than the repo</summary>

The marketplace clone is cached. Run the two commands in
[Keeping it updated](#keeping-it-updated) — the marketplace update refreshes
the clone, the plugin update installs the new version. Then restart sessions.
</details>

<details>
<summary><code>claude plugin update first-playable</code> says "not found"</summary>

Use the full name: `claude plugin update first-playable@first-playable`.
</details>

<details>
<summary>Unity MCP Server page missing in Project Settings</summary>

The `com.unity.ai.assistant` package isn't installed (or still compiling).
Install it via Package Manager → `[+]` → *Install package by name…* — note
Unity 6.5 moved the menu to `Window → Package Management → Package Manager`.
</details>

<details>
<summary>claude-code doesn't appear under Connected Clients</summary>

Make sure the server Status is **Running** (press Start), then launch `claude`
from the Unity **project folder**. First connection needs a one-time approval
in the Unity settings page. If it still fails, check
`Show Debug Logs` on the same page.
</details>

<details>
<summary><code>unity status</code> says no Editor instances (<code>STATUS_NO_INSTANCES</code>)</summary>

Either no Editor is open for the project, the Pipeline package is missing
(`unity pipeline install`), or the Editor is still loading — give it ~30s. If
you launched with `unity open` while signed out, Hub is sitting on its sign-in
screen and the Editor never started: run `unity auth login`. Don't detect the
Editor by process name — the CLI's own auth broker is also called `unity`.
</details>

<details>
<summary><code>unity test</code> exits <code>6</code> right away</summary>

`6` means "no verdict", never "tests failed" (that's `8`). The two causes we hit:
`EDITOR_LICENSING_FAILURE` (CLI not signed in — `unity auth login`), and
*"already open in a running Editor"* — headless runs need that project's Editor
closed. With the Editor open, the agent runs tests through it instead.
</details>

<details>
<summary><code>unity command quit</code> fails with a <code>DontDestroyOnLoad</code> error</summary>

A bug in `com.unity.pipeline` `0.8.0-exp.1`: the quit command fails in edit
mode. Close the Editor normally.
</details>

---

## Roadmap

| Version | Scope | Status |
|---|---|---|
| v0.1 | Design interview, review, scoping, templates | ✅ done |
| v0.2 | Unity references, asmdef templates, unity-guard hook, official Unity MCP setup docs | ✅ done |
| v0.3 | Hardening from a real Unity 6 project run: play-mode deadlock guard, evidence rules for instrumented measurements, vacuous-test detection | ✅ done |
| v0.4 | Unity CLI as a second transport, validated on the same project; guard marker fixed for test runs | ✅ done |
| v0.5 | Playtest structuring and spec feedback loop | 🔜 next |
| v1.0 | Primitive-only example project, Windows/macOS validation, release automation | planned |

Details in [CHANGELOG.md](CHANGELOG.md). Want to help? See
[CONTRIBUTING.md](CONTRIBUTING.md) — real-world usage reports are the most
valuable contribution right now.

## License

[MIT](LICENSE)
