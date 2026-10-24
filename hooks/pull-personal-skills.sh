#!/usr/bin/env bash
# SessionStart hook: pull the personal skills repo so every session starts
# from its latest rules, then link any skill added upstream.

hook_path="${BASH_SOURCE[0]}"
[ -L "$hook_path" ] && hook_path=$(readlink "$hook_path")
repo_dir=$(cd "$(dirname "$hook_path")/.." && pwd -P) || exit 0

before=$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null) || exit 0
if ! git -C "$repo_dir" fetch -q 2>/dev/null || ! git -C "$repo_dir" merge --ff-only -q "@{u}" >/dev/null 2>&1; then
  echo "personal skills: pull failed in $repo_dir (offline, diverged, or an upstream change touches a locally edited file); using the current copy"
  exit 0
fi
after=$(git -C "$repo_dir" rev-parse HEAD)

[ "$before" = "$after" ] && exit 0
"$repo_dir/install.sh" --skills-only >/dev/null 2>&1
echo "personal skills: updated to $(git -C "$repo_dir" log -1 --format='%h %s')"
