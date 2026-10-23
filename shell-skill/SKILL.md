---
name: shell-skill
description: Use BEFORE writing or changing any bash/sh script (.sh files, curl+jq REST calls, helper scripts). Covers secrets out of the command line, HTTP status checks, following the file's naming convention (snake_case by default), local vars, jq -r null checks, = not == inside [ ].
---

# Shell scripts

## General
- Follow the existing naming convention of the file and repo; with none, name functions in snake_case.
- Declare every function-local variable with `local` (bash; plain POSIX `sh` has no `local`).
- When calling a REST API via `curl`, request JSON and parse it with `jq -r`, rather than string-slicing the raw response.
- Check the HTTP status before parsing the body: capture it with `curl -sS -w '%{http_code}'` (writing the body to a file or variable), and handle a non-2xx status explicitly. Don't use `-f`, which discards the error body you need to report.
- After parsing a `jq -r` field that may be absent, check for both the empty string and the literal string `"null"`: `[ -z "$var" ] || [ "$var" = "null" ]`. `jq -r` prints `null` as the string `"null"`, so an empty-only check misses it.
- Inside `[ ... ]` (single-bracket `test`), compare strings with `=`, never `==`. `==` inside `[ ]` fails with `= not found` on at least one real zsh setup, though many others accept it. `==` is fine inside `[[ ... ]]`.
- Never pass a secret as a command-line argument: it shows in `ps` and in the terminal title. Write it to a temp file (`hdr=$(mktemp)`, `curl -H @"$hdr"`), remove it on exit (`trap 'rm -f "$hdr"' EXIT`), and keep `set -x` off around it.
