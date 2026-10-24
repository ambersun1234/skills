#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
hooks_dir="$claude_dir/hooks"
settings_file="$claude_dir/settings.json"
timestamp=$(date +%Y%m%d%H%M%S)

check_dependencies() {
  local tool
  for tool in jq bash; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "missing dependency: $tool" >&2
      exit 1
    fi
  done
}

# ~/.claude/skills must be a real directory holding one link per skill, so
# other installers (company skills) and Claude Code's own synced skills land
# there instead of inside this repo.
prepare_skills_dir() {
  local target="$claude_dir/skills"
  local current

  if [ -L "$target" ]; then
    current=$(cd "$target" && pwd -P)
    rm "$target"
    mkdir "$target"
    echo "skills: replaced the $target -> $current link with a real directory"
    if [ "$current" = "$repo_dir" ] && [ -d "$repo_dir/synced" ]; then
      mv "$repo_dir/synced" "$target/synced"
      echo "skills: moved synced/ out of this repo into $target"
    fi
    return
  fi

  mkdir -p "$target"
}

link_skill() {
  local name="$1"
  local source="$repo_dir/$name"
  local target="$claude_dir/skills/$name"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "skill: $name already linked"
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "skill: $target already exists and is not this repo's link, leaving it alone" >&2
    return
  fi

  ln -s "$source" "$target"
  echo "skill: linked $name"
}

link_hook() {
  local name="$1"
  local source="$repo_dir/hooks/$name"
  local target="$hooks_dir/$name"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "hook: $name already linked"
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    mv "$target" "$target.bak-$timestamp"
    echo "hook: backed up existing $name to $name.bak-$timestamp"
  fi

  ln -s "$source" "$target"
  echo "hook: linked $name"
}

register_hook() {
  local event="$1"
  local matcher="$2"
  local name="$3"
  local command="bash $hooks_dir/$name"
  local updated

  updated=$(jq \
    --arg event "$event" \
    --arg matcher "$matcher" \
    --arg name "$name" \
    --arg command "$command" '
    def registered:
      [(.hooks[$event] // [])[].hooks[]?.command | select(endswith("/hooks/" + $name))] | length > 0;
    def group:
      { hooks: [{ type: "command", command: $command, timeout: 5 }] }
      + (if $matcher == "" then {} else { matcher: $matcher } end);
    if registered then . else .hooks[$event] = ((.hooks[$event] // []) + [group]) end
  ' "$settings_file")

  if [ "$updated" = "$(jq . "$settings_file")" ]; then
    echo "settings: $name already registered"
    return
  fi

  printf '%s\n' "$updated" > "$settings_file"
  echo "settings: registered $name on $event"
}

link_skills() {
  local skill_path
  for skill_path in "$repo_dir"/*/SKILL.md; do
    [ -L "$(dirname "$skill_path")" ] && continue
    link_skill "$(basename "$(dirname "$skill_path")")"
  done
}

main() {
  check_dependencies

  if [ "${1:-}" = "--skills-only" ]; then
    prepare_skills_dir
    link_skills
    return
  fi

  mkdir -p "$claude_dir" "$hooks_dir"
  [ -f "$settings_file" ] || echo '{}' > "$settings_file"
  cp "$settings_file" "$settings_file.bak-$timestamp"

  prepare_skills_dir
  link_skills

  local name
  for name in require-skills.sh require-github-workflow.sh skill-reminder.sh pull-personal-skills.sh; do
    link_hook "$name"
  done

  register_hook PreToolUse "Edit|Write|MultiEdit" require-skills.sh
  register_hook PreToolUse "Bash" require-github-workflow.sh
  register_hook UserPromptSubmit "" skill-reminder.sh
  register_hook SessionStart "" pull-personal-skills.sh

  echo "done. settings backup: $settings_file.bak-$timestamp"
}

main "$@"
