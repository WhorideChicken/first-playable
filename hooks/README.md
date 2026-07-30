# Hooks (planned — v0.2)

FirstPlayable will use hooks for **risk detection**, not automation:

- Warn when a Scene/Prefab/`.asset` YAML file is edited directly as text
- Warn when anything under `Assets/ThirdParty` is modified
- Warn when a `.meta` file is deleted
- Warn when a feature is marked complete without a verification report

Unity compilation and tests are always run through explicit skills
(`/first-playable:verify`), never through hooks.

Not implemented yet — see [CHANGELOG.md](../CHANGELOG.md) for the roadmap.
