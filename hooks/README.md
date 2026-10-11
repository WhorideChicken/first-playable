# Hooks

FirstPlayable uses hooks for **risk detection**, not automation. The
`unity-guard` PreToolUse hook ([hooks.json](hooks.json) →
[scripts/unity-guard.sh](../scripts/unity-guard.sh)) intercepts risky
operations and asks for confirmation instead of letting them happen silently:

| Detected operation | Why it's risky |
|---|---|
| Editing `Assets/**/*.cs` while Unity is in play mode (marker file from `templates/unity/PlayModeMarker.cs`) | deferred recompile locks MCP; only a human Stop — or the Unity CLI's `editor_stop` / `cancel_tests` — gets out |
| Editing `.unity` / `.prefab` / `.asset` / `.anim` / `.mat` etc. as text | Unity-serialized YAML corrupts easily (fileID references, stripped components); use Unity MCP or Editor scripts |
| Writing under `Assets/ThirdParty` | changes are lost on package updates and may violate licenses |
| Writing or deleting `.meta` files | `.meta` holds asset GUIDs; breaking them silently breaks every reference |

Design notes:

- **Ask, not deny** — every warning can be overridden by the user, because
  sometimes a hand-edit is genuinely intended (e.g. trivial merge conflict).
- **Fail-open** — if the hook can't parse its input it stays silent. A broken
  guard must never block normal, non-Unity work.
- Requires `bash` (present on macOS/Linux; on Windows, Claude Code uses Git
  Bash, which is a Claude Code requirement anyway).
- **It only sees the Edit/Write tools.** A file written from a shell
  (`sed`, `python`, `Set-Content`, `>`) bypasses it entirely. This is not
  theoretical: in v0.4.0 validation the agent patched a script via `python`
  during a PlayMode test run and deadlocked the Editor. The rules in
  `verify` apply to every write path; the hook is a net, not the rule.

Unity compilation and tests are always run through explicit skills
(`/first-playable:verify`), never through hooks.
