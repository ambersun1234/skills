#!/usr/bin/env bash
# Stop hook: while continue mode is on for this session, block Claude from
# ending the turn. Gives up after max_blocks so a stuck loop can't run forever.

state_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/state/continue"
max_blocks=20

main() {
  local session_id marker count reason
  session_id=$(jq -r '.session_id // empty')
  [ -z "$session_id" ] && return 0

  marker="$state_dir/$session_id"
  [ -f "$marker" ] || return 0

  count=$(cat "$marker")
  [[ "$count" =~ ^[0-9]+$ ]] || count=0
  if [ "$count" -ge "$max_blocks" ]; then
    rm -f "$marker"
    return 0
  fi
  echo $((count + 1)) > "$marker"

  reason="Continue mode is on ($((count + 1))/$max_blocks): the task is not marked done. Check your todo list and keep working on the next open item. Only if the task is done and verified, or you must stop for a user decision, an approval or a blocker you can't get past, run rm \"$marker\" first and then end the turn."
  jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
}

main
