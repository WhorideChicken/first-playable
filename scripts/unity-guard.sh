#!/usr/bin/env bash
# FirstPlayable unity-guard hook (PreToolUse)
#
# Detects risky operations on Unity projects and asks the user to confirm
# instead of letting them happen silently:
#   1. Editing Unity-serialized YAML as text (.unity, .prefab, .asset, ...)
#   2. Modifying anything under Assets/ThirdParty
#   3. Writing or deleting .meta files
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

# Assets/ThirdParty (both / and \ separators; JSON doubles backslashes)
case "$file_path" in
  *Assets/ThirdParty/*|*Assets*ThirdParty*)
    ask "FirstPlayable: this file is under Assets/ThirdParty. Third-party originals must not be modified - changes are lost on package updates and may violate licenses. Wrap or extend from Assets/_Game instead."
    ;;
esac

case "$file_path" in
  *.meta)
    ask "FirstPlayable: .meta files are managed by Unity and contain asset GUIDs. Hand-editing or regenerating them silently breaks every reference to this asset. Let Unity handle it."
    ;;
  *.unity|*.prefab|*.controller|*.anim|*.overrideController|*.physicMaterial|*.physicsMaterial2D|*.mat|*.asset)
    ask "FirstPlayable: this is Unity-serialized YAML. Direct text edits corrupt scenes/prefabs easily (fileID references, stripped components). Use Unity MCP or an Editor script instead. Confirm only if you accept the risk."
    ;;
esac

exit 0
