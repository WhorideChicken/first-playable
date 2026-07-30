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
