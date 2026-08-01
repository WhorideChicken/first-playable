#!/usr/bin/env bash
# FirstPlayable unity-guard hook (PreToolUse)
#
# Detects risky operations on Unity projects and asks the user to confirm
# instead of letting them happen silently:
#   1. Editing C# while the Editor is in Play Mode (causes an MCP deadlock)
#   2. Editing Unity-serialized YAML as text (.unity, .prefab, .asset, ...)
#   3. Modifying anything under Assets/ThirdParty
#   4. Writing or deleting .meta files
#
# Design: fail-open. If parsing fails, exit 0 silently — a broken hook must
# never block normal (non-Unity) work. Detection is best-effort, not a
# security boundary.

input=$(cat)

# --- helpers -----------------------------------------------------------------

extract() {
  # extract "<key>":"<value>" (first occurrence, no unescaping)
  printf '%s' "$input" | tr '\n' ' ' \
    | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
}

ask() {
  # $1 = reason (must not contain double quotes or backslashes)
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}' "$1"
  exit 0
}

tool_name=$(extract "tool_name")

# --- Bash: deleting .meta files ---------------------------------------------

if [ "$tool_name" = "Bash" ]; then
  command_str=$(extract "command")
  case "$command_str" in
    *rm\ *.meta*|*rm\ -*meta*|*Remove-Item*meta*|*del\ *.meta*)
      ask "FirstPlayable: this command may delete .meta files. Unity manages .meta files itself - deleting them breaks asset references (GUIDs). Confirm only if you know the asset itself is also being removed."
      ;;
  esac
  exit 0
fi

# --- Edit/Write/MultiEdit: risky file targets --------------------------------

file_path=$(extract "file_path")
[ -z "$file_path" ] && exit 0

# Normalize separators: JSON doubles backslashes on Windows paths
norm=$(printf '%s' "$file_path" | sed 's|\\\\|/|g; s|\\|/|g')

# 1. Assets/ThirdParty
case "$norm" in
  */Assets/ThirdParty/*|Assets/ThirdParty/*)
    ask "FirstPlayable: this file is under Assets/ThirdParty. Third-party originals must not be modified - changes are lost on package updates and may violate licenses. Wrap or extend from Assets/_Game instead."
    ;;
esac

# 2. C# edits while the Editor is in Play Mode  ->  MCP deadlock
#    Unity defers recompilation during play, MCP refuses commands while
#    isCompiling is true, and the agent has no way to stop play mode:
#    only a human pressing Stop breaks the cycle.
case "$norm" in
  */Assets/*.cs|Assets/*.cs)
    if [ "$norm" != "${norm%%/Assets/*}" ]; then
      proj_root="${norm%%/Assets/*}"
    else
      proj_root="${CLAUDE_PROJECT_DIR:-.}"
    fi
    if [ -f "$proj_root/Temp/firstplayable_playmode" ]; then
      ask "FirstPlayable: Unity appears to be in PLAY MODE. Editing a script now defers recompilation, which locks the MCP bridge (COMPILATION_IN_PROGRESS) and leaves no way to exit play mode - a human must press Stop. Exit play mode first, then edit. (If Unity is not actually playing, delete Temp/firstplayable_playmode - it is a stale marker.)"
    fi
    ;;
esac

# 3. Unity-managed file formats
case "$norm" in
  *.meta)
    ask "FirstPlayable: .meta files are managed by Unity and contain asset GUIDs. Hand-editing or regenerating them silently breaks every reference to this asset. Let Unity handle it."
    ;;
  *.unity|*.prefab|*.controller|*.anim|*.overrideController|*.physicMaterial|*.physicsMaterial2D|*.mat|*.asset)
    ask "FirstPlayable: this is Unity-serialized YAML. Direct text edits corrupt scenes/prefabs easily (fileID references, stripped components). Use Unity MCP or an Editor script instead. Confirm only if you accept the risk."
    ;;
esac

exit 0
