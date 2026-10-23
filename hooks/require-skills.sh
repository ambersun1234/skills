#!/usr/bin/env bash
# PreToolUse hook for Edit|Write|MultiEdit: block code edits until the matching
# local skills have been loaded with the Skill tool in this session.

input=$(cat)
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")

[ -z "$file_path" ] && exit 0
[ -z "$transcript" ] || [ ! -f "$transcript" ] && exit 0

hook_path="${BASH_SOURCE[0]}"
[ -L "$hook_path" ] && hook_path=$(readlink "$hook_path")
skills_repo=$(cd "$(dirname "$hook_path")/.." 2>/dev/null && pwd -P)

case "$file_path" in
  */.claude/*|*/scratchpad/*) exit 0 ;;
esac
[ -n "$skills_repo" ] && case "$file_path" in "$skills_repo"/*) exit 0 ;; esac

required=()
case "$file_path" in
  *.go|*.ts|*.tsx|*.js|*.jsx|*.java|*.py|*.sh|*.bash) required+=(code-review-skill) ;;
  *) exit 0 ;;
esac

case "$file_path" in
  */tests/*_test.go) required+=(integration-test-skill) ;;
  *_test.go|*.test.ts|*.test.tsx|*.test.js|*.spec.ts|*.spec.tsx|*/src/test/*) required+=(unit-test-skill) ;;
esac

case "$file_path" in
  *.sh|*.bash) required+=(shell-skill) ;;
  */middlewares/*|*/middleware/*) required+=(middleware-skill) ;;
esac

missing=()
for skill in "${required[@]}"; do
  grep -qE "\"skill\": ?\"${skill}\"" "$transcript" || missing+=("$skill")
done

[ ${#missing[@]} -eq 0 ] && exit 0

{
  echo "Blocked: before editing $file_path, load these skills with the Skill tool: ${missing[*]}."
  echo "Also check whether database-skill, logging-skill, cache-skill or message-queue-skill apply to this change, and load them too if so."
  echo "Then retry the edit."
} >&2
exit 2
