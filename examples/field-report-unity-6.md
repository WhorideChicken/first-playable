# Field Report — Unity 6, Features F01–F07

*What broke when FirstPlayable met a real project, and what changed because of it.*

This is the source material behind **v0.3.0**. Every item below is an incident
that actually occurred while building a physics-action prototype in Unity 6.5
with the workflow driving a Unity MCP connection — no hypotheticals, no
"potential risks". It is published because a workflow that claims *"verified
means you ran it"* should be able to show its own failures.

The full original operations log (Korean) lives in the game project as
`Docs/Process/WORKFLOW_PITFALLS.md`. This is the distilled, English version.

---

## Incidents and fixes

| # | Incident | Times | Severity | Fixed in v0.3.0 by |
|---|---|---:|---|---|
| A1 | Editing a script during play mode deadlocked the editor | 2 | **critical** | play-mode marker + `unity-guard` case |
| A2 | `runInBackground` off → frames frozen → **wrong `VERIFIED`** | 1 | high | blocking preflight in `bootstrap` |
| A3 | Domain-reload silence misread as failure | dozens | medium | retry protocol in `references/unity-mcp.md` |
| B1 | Instrumentation conditions ≠ real play → **conclusion inverted** | 1 | **critical** | evidence rules in `verify` |
| B2 | Assertions that pass when nothing happened | 2 | high | transient-state rule in `references/unity-testing.md` |
| B3 | String correct, rendering wrong (missing glyphs) | 1 | medium | UI rule in `verify` |
| C1 | Recompile nulled inspector references | 1 | high | wiring order + `Verify()` in `feature` |
| C2 | Diagnostic value (×300) nearly committed | 1 | medium | exit gate in `verify` / `playtest` |

---

## The three that mattered most

### A1 — The deadlock nobody's component caused

```text
play mode running  →  script edited
      ↓
Unity defers recompilation  ("Script Changes While Playing")
      ↓
MCP refuses every command   (isCompiling == true)
      ↓
the agent has no way to exit play mode
      ↓
only a human pressing Stop breaks the cycle
```

Neither Unity nor the MCP server is misbehaving — each guard is individually
correct, and the *combination* is a deadlock. It happened twice; the second
time ran 26 minutes before the developer intervened manually.

**Fix:** an `[InitializeOnLoad]` marker writes `Temp/firstplayable_playmode`
during play mode, and the existing `unity-guard` PreToolUse hook refuses `.cs`
edits while it exists. The guard already had the right shape for YAML and
`.meta` files — this was one more case in the same place.

### A2 → B1 — Two different ways to be confidently wrong

**A2:** an unfocused Unity Editor does not advance frames in play mode. An
agent-driven editor is *always* unfocused, so `Time.frameCount` stayed
identical across samples and every runtime reading was stale. A camera-tracking
item had to be retracted from `VERIFIED` to `UNVERIFIED`.

**B1** is subtler and cost more. Hit-stop was instrumented across 190 impacts:
`FreezeCount = 0`. The report concluded hit-stop probably never triggers in
normal play. When a human played it, hit-stop triggered *excessively* —
stuttering. The instrumented run had **no continuous input**, so the ball
decelerated and never crossed the damage threshold. Real players hold input,
so it always did.

The conclusion wasn't just unsupported — it was **exactly backwards**, and it
would have driven tuning in the wrong direction.

**Fix:** runtime measurements must state their conditions, and measurements
whose conditions differ from real play are `INFERRED`, not `VERIFIED`. Plus a
rule that generalizes the failure:

> **A negative conclusion can never be `VERIFIED` by instrumentation alone.**
> "X never triggers" is indistinguishable from "I failed to create the
> conditions for X."

### B2 — Tests that pass when nothing happens

```csharp
while (stop.IsFrozen) yield return null;
Assert.IsFalse(stop.IsFrozen);                 // already false at frame 0
Assert.That(Time.timeScale, Is.EqualTo(1f));   // never changed
```

Both assertions describe the *end* state — identical to the state where the
feature never fired. A second case: a test named `..._LingersThenDespawns`
only verified the corpse existed; pool return and reuse went unchecked while
the spec table listed them as covered.

**Fix:** for transient state (hit-stop, cooldowns, invulnerability, knockback),
expose a counter and assert `> 0` *before* asserting the end state. And the
`unity-qa` agent now audits by assertion content rather than test name, asking:
*would this test fail if the rule were broken?*

---

## What held up (unchanged in v0.3.0)

Recorded for fairness — these caught real defects during the same run:

- **Rule-ID traceability.** A tuning problem was correctly escalated into a new
  game rule instead of a magic-number tweak. Had it been tuned numerically, the
  same bug would have returned with the next weapon.
- **Core / Gameplay / Presentation split.** The "Gameplay cannot reference
  Presentation" constraint forced a subscription-based design that was simply
  better than the shortcut it prevented.
- **One variable per experiment.** Turning hit-stop off as a control was faster
  and more conclusive than building an instrument for it.
- **Success criteria written before the change.** One experiment was correctly
  judged a failure; graded afterwards, "seems a bit better" would have passed.
- **Evidence labels.** Because a runtime observation was honestly marked
  `UNVERIFIED`, there was a documented basis for correcting the report when it
  later turned out to be wrong.
- **The `unity-guard` hook.** It blocked direct YAML edits in practice — and
  had the right structure for the A1 fix to slot into.

---

## The meta-point

Six of the eight incidents produced **passing checks with wrong conclusions**,
not crashes. That is the actual failure mode of AI-assisted development: not
code that fails loudly, but verification that succeeds falsely.

Which is why the fixes are mostly *epistemic* rather than technical — rules
about what may be called verified, what a measurement's conditions must
disclose, and which assertions are allowed to count as coverage.
