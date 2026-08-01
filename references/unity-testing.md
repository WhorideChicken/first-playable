# Unity Testing Reference

Detailed guidance for the `feature` and `verify` skills.

## 1. The humble object pattern — why Core has no engine references

The single highest-leverage decision for testability: game **rules** live in
plain C# classes (`Game.Core`), and MonoBehaviours (`Game.Gameplay`) are thin
adapters that feed them input and apply their output.

```csharp
// Game.Core — pure C#, EditMode-testable in milliseconds, no Unity at all
public sealed class MoveLogic
{
    public MoveConfig Config { get; }
    public MoveLogic(MoveConfig config) => Config = config;

    // MOVE-001: camera-relative movement while grounded, suppressed during knockback
    public Vector3d Step(MoveState state, MoveInput input, double dt) { /* ... */ }
}

// Game.Gameplay — humble adapter, almost nothing to test
public sealed class PlayerMotor : MonoBehaviour
{
    [SerializeField] private MoveConfigAsset config;   // TEMPORARY values live here
    private MoveLogic logic;
    private void FixedUpdate()
    {
        var result = logic.Step(CaptureState(), CaptureInput(), Time.fixedDeltaTime);
        Apply(result); // CharacterController.Move etc.
    }
}
```

Guideline: if a behavior rule from the Feature Spec can't be expressed as a
`MoveLogic`-style test, the split is wrong — push more logic down into Core.
Note `UnityEngine.Vector3` is unavailable in a `noEngineReferences` assembly;
either define small math structs in Core or use `Unity.Mathematics` via an
explicit reference. For a First Playable, simple custom structs are fine.

## 2. EditMode tests

- Live in `Assets/_Game/Tests/EditMode/` with the EditMode asmdef from
  `templates/unity/`.
- Test Core logic against the rules in the Feature Spec. **Name tests after
  rule IDs**: `Move001_GroundedInput_MovesCameraRelative`,
  `Move001_Knockback_SuppressesInput`.
- Fast, no scene, no frames. This is where the bulk of coverage goes.
- Run via MCP, or `Window → General → Test Runner → EditMode` manually, or CLI:
  `Unity -batchmode -runTests -testPlatform EditMode -projectPath . -testResults results.xml`
  (CLI requires the Editor to be closed).

## 3. PlayMode tests

- Live in `Assets/_Game/Tests/PlayMode/`.
- Use `[UnityTest]` + `IEnumerator` when frames must pass:

```csharp
[UnityTest]
public IEnumerator Move001_PlayerMoves_WhenInputHeld()
{
    var go = new GameObject("player", typeof(CharacterController), typeof(PlayerMotor));
    // arrange config with test values...
    var start = go.transform.position;
    yield return new WaitForSeconds(0.5f);   // frames advance
    Assert.Greater(Vector3.Distance(start, go.transform.position), 0.1f);
}
```

- Prefer constructing minimal GameObjects in the test over loading full scenes —
  scene-loading tests are slower and break when scenes change. Load the actual
  `FirstPlayable` scene only in a small number of smoke tests
  (`SceneManager.LoadScene` in `[UnitySetUp]`, scene added to Build Settings
  or loaded via `LoadSceneMode` with `EditorBuildSettings` entry).

### Transient state: assert that it HAPPENED before asserting that it ended

Hit-stop, invulnerability, cooldowns, knockback — anything that switches on
briefly and back off — produces tests that pass vacuously:

```csharp
// Passes even if the freeze never triggered once.
while (stop.IsFrozen) yield return null;
Assert.IsFalse(stop.IsFrozen);                 // already false at frame 0
Assert.That(Time.timeScale, Is.EqualTo(1f));   // never changed
```

Both assertions describe the *end* state, which is identical to the state where
nothing ever happened. Expose an observable counter (`FreezeCount`, `HitCount`,
`SpawnCount`) and assert it first:

```csharp
Assert.Greater(stop.FreezeCount, 0, "hit-stop never triggered");   // it happened
while (stop.IsFrozen) yield return null;
Assert.That(Time.timeScale, Is.EqualTo(1f).Within(0.001f));        // it ended
```

Same rule for pooling, despawn, and respawn: asserting "the corpse is still
there" does not verify "it returned to the pool and was reused".

### `Contains()` verifies a string, not a rendering

`Assert.IsTrue(label.text.Contains("생존"))` passes while the screen shows
`□□`, because the TMP font asset has no glyph for those characters. Text
rendering is verified by a clean console (no *"character with Unicode value …
was not found"* warnings) plus a visual check — never by string assertions
alone.

### Waiting for test results

When results are written to a file (e.g. `Temp/firstplayable_test_result.txt`),
wait once with a generous timeout instead of polling in a loop — repeated
round-trips are the single biggest time sink in agent-driven verification.
Budget roughly **30s for EditMode** and **2–4 minutes for PlayMode**, and treat
overrun as a failure to report, not a reason to keep polling.

### Common PlayMode pitfalls

| Pitfall | Symptom | Fix |
|---|---|---|
| Physics needs fixed steps | flaky distance assertions | `yield return new WaitForFixedUpdate()` loops, assert ranges not exact values |
| `Time.timeScale` leaked from a previous test | everything fast/slow | reset in `[TearDown]` |
| Singletons/static state across tests | order-dependent failures | reset statics in `[SetUp]`; prefer instance state in Core |
| Input System hardware input | can't simulate keys | use `InputTestFixture` from the Input System package's test helpers |
| Async/Awaitable in Unity 6 | test ends before logic | wrap in `[UnityTest]` coroutine and poll for completion with a timeout |

## 4. What NOT to test

For a First Playable, skip: visual appearance, exact tuning values (they're
`TEMPORARY` — assert relationships, e.g. "decel distance shrinks when decel
time shrinks", not "speed == 5"), engine behavior itself, and anything listed
under Manual play checks in the spec. Over-testing tuning values makes every
playtest iteration break the suite — that trains people to delete tests.

## 5. Coverage contract with the Feature Spec

For every entry under `## Behavior rules` in the spec, one of:
1. An EditMode test (preferred), or
2. A PlayMode test (when frames/physics are essential), or
3. An explicit line under `## Manual play checks` explaining why it's human-only.

The `unity-qa` agent audits exactly this mapping. Unmapped rules are gaps.

Match rules to tests **by what the test asserts, not by its name.** A test
called `Enm004_DeadDrone_LingersThenDespawns` that only checks the corpse
exists is not coverage for the despawn rule, and a spec table listing it as
verified is actively misleading. The question to ask of every mapping: *would
this test fail if the rule were broken?* If not, it is a gap.
