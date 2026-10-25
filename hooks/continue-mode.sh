#!/usr/bin/env bash
# UserPromptSubmit hook: a prompt asking to continue or finish turns on
# continue mode for this session, so continue-stop.sh keeps Claude working.
# Any other prompt turns it off.

state_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/state/continue"
keywords='continue|keep going|until done|finish (it|all)|complete (it|all)|繼續|做完|跑完'

main() {
  local input session_id prompt marker
  input=$(cat)
  session_id=$(jq -r '.session_id // empty' <<<"$input")
  prompt=$(jq -r '.prompt // empty' <<<"$input")
  [ -z "$session_id" ] && return 0

  marker="$state_dir/$session_id"
  if grep -qiE "$keywords" <<<"$prompt"; then
    mkdir -p "$state_dir"
    echo 0 > "$marker"
    echo "Continue mode is on: load continue-skill. The Stop hook blocks ending the turn until you run: rm \"$marker\""
    return 0
  fi

  rm -f "$marker"
}

main
