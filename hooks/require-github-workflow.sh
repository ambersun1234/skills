#!/usr/bin/env bash
# PreToolUse hook for Bash: block GitHub writes and pushes until the
# github-workflow skill has been loaded in this session.

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")

[ -z "$command" ] && exit 0
[ -z "$transcript" ] || [ ! -f "$transcript" ] && exit 0

pattern='(^|[;&|(]|\s)(gh (pr (create|edit|comment|merge|review|ready|close)|issue (create|edit|comment|close|reopen))|git push)\b'
api_write='gh api .*(-X ?(POST|PATCH|PUT|DELETE)|--method ?(POST|PATCH|PUT|DELETE)|(^|\s)-[fF] |graphql)'

if ! grep -qE "$pattern" <<<"$command" && ! grep -qE "$api_write" <<<"$command"; then
  exit 0
fi

grep -qE '"skill": ?"github-workflow"' "$transcript" && exit 0

echo "Blocked: load the github-workflow skill with the Skill tool before writing to GitHub or pushing, then retry." >&2
exit 2
