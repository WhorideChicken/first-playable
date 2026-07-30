# Game Feel Tuning Reference

Vocabulary and diagnosis tables for the `playtest` skill: mapping what players
*say* to parameters that might *cause* it. Always generate 2–3 hypotheses per
complaint — the first guess is wrong often enough to matter.

## 1. Movement complaints

| Player says | Candidate causes (check in this order) |
|---|---|
| "slippery / slides too far" | deceleration time too long; ground friction low; velocity not zeroed on input release |
| "stiff / robotic" | acceleration instant (no ramp); rotation snap instead of interpolation; animation blending absent |
| "sluggish / laggy input" | input polled in `Update` but applied in `FixedUpdate` without buffering; acceleration time too long; Input System processing/deadzone too high |
| "jump feels bad" | no coyote time (~0.1s grace after leaving a ledge); no jump buffering (~0.1s pre-landing input queue); gravity symmetric (fall should usually be ~1.5–2× rise); no variable jump height on early release |
| "turns feel wide" | rotation slerp time too long; movement fully velocity-based with high inertia; camera-relative input recomputed mid-turn |
| "random / not my fault" | physics interactions dominating input (mass ratios, bouncy materials); hidden state affecting control (buffs, surface types) without feedback |

Typical starting values (all `TEMPORARY`, tune from here): walk accel time
0.05–0.15s, decel time 0.02–0.10s (decel ≤ accel for responsive stops),
rotation 0.05–0.12s, coyote 0.08–0.12s, jump buffer 0.1–0.15s.

## 2. Camera complaints

| Player says | Candidate causes |
|---|---|
| "camera lags behind" | follow damping too high; damping applied per-axis unevenly (check Y vs XZ) |
| "camera too twitchy" | zero damping; look-ahead overshooting; unsmoothed target from `Update` vs `FixedUpdate` mismatch (jitter) |
| "I can't see where I'm going" | no look-ahead in movement direction; FOV too narrow; camera too low/close |
| "motion sick" | rotational damping oscillating; FOV changes too fast; screen shake amplitude/frequency too high |

Cinemachine note: damping lives on the body component of the active camera;
jitter usually means target moves in `FixedUpdate` but Brain updates on
`Update` — align the Brain's Update Method with how the target moves.

## 3. Feedback & readability complaints

| Player says | Candidate causes |
|---|---|
| "hits feel weak" | no hit-stop (try 0.04–0.08s freeze); no impact SFX layer; no knockback on target; effect not synced to contact frame |
| "didn't notice X happened" | feedback priority collision — the important event has weaker feedback than a cosmetic one; missing distinct audio channel; effect off-screen |
| "didn't know why I died" | failure cause communicated only once or only visually; death faster than reaction time without telegraph |
| "UI feels dead" | no state-change tweens; instant number changes (no count-up); no button press feedback |

## 4. Difficulty & retry complaints

| Player says | Candidate causes |
|---|---|
| "unfair" | telegraphs shorter than human reaction (~0.25s minimum, more with visual noise); hitboxes larger than visuals; RNG deciding outcomes the player attributes to skill |
| "boring / too easy" | dominant strategy exists (design issue → back to GAME_RULES, not tuning); failure has no cost; success needs no decision |
| "don't want to retry" | restart loop too long (target: < 3s from fail to control); progress fully reset when partial persistence was expected; failure feedback punishing rather than informative |

## 5. Experiment discipline

- Change **one parameter per experiment**. Two complaints = two experiments,
  even in the same session.
- Write success criteria before changing the value (the playtest skill enforces this).
- Log the old value, new value, and the player's quote in the playtest record —
  quotes decay fast and are the actual data.
- After ~3 failed tuning experiments on the same complaint, suspect the design
  rather than the numbers: escalate from Feature Spec tuning table back to
  GAME_RULES / CORE_LOOP, and record the pivot in `Docs/Decisions/`.
