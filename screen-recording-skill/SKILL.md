---
name: screen-recording-skill
description: Use BEFORE any use of the screen: recording a test, a Claude in Chrome session (clicks, screenshots, checking a design canvas), or bringing an app to the front. Covers the shared screen lock and round robin, readable text on any display, macOS ffmpeg + Terminal mechanics, cleanup, and command hygiene in a recorded terminal.
---

# Screen use and recording

What a take must show, how to review it, and how to report it are in `test-report-skill`; load it too when recording a test.

## Screen lock
Sessions share one display; two at once ruin both takes. Take the lock before anything that drives the screen: a recording, Claude in Chrome (clicks, screenshots, checking a canvas), bringing an app to the front. Work that never touches the display needs none. The user saying the screen is free doesn't mean other sessions are idle.
- **Path:** `~/.claude/locks/screen-recording.lock`, a directory (`mkdir` is atomic): `mkdir -p ~/.claude/locks && mkdir ~/.claude/locks/screen-recording.lock`.
- **Take it in its own step and read the result**, never batched with a Chrome call (`tabs_context_mcp` with `createIfEmpty` opens a window).
- **Owner file** inside: session name (`ListAgents`), issue, start time, cases.
- **Hold it** for every take, at least one whole case (setup through cleanup). Release (`rm -rf`) right after the last take's cleanup, pass or fail.
- **Round robin:** if someone is waiting, finish a small batch (about 10 minutes of work, ending at a case boundary), release, hand over to the next session in the queue, and queue again behind the others. Only a session the user marked urgent keeps it to the end. Name and message the next session.
- **Taken:** `SendMessage` the owner what and how long, then wait in a background `until [ ! -d <lock> ]` loop. Never poll the owner.
- **Release:** message everyone who asked.
- **Stale** only if the owner is gone from `ListAgents` and none of its processes (e.g. `ffmpeg`) lives. Remove it and tell the user.

## Recording
- One video per case. A screenshot is never the evidence, only an in-flight check.
- Any display size is fine, as long as the text is clearly readable in the final video. Find the display's `avfoundation` index with `ffmpeg -f avfoundation -list_devices true -i ""`.
- Note the frontmost app before (`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`) and bring it back after.
- Afterwards close every Terminal window and Chrome tab the test opened, and archive (not delete) every email it triggered. Touch nothing else.

**macOS mechanics:**
- Capture: `ffmpeg -loglevel error -y -f avfoundation -capture_cursor 1 -framerate 15 -i "<screen index>" out.mkv` in the background; stop with `kill -INT <pid>` + `wait`. Re-encode: `-vf "scale=2048:-2,fps=12" -c:v libx264 -crf 26 -pix_fmt yuv420p -an`.
- Window: `do script ""`, read `id of window 1`. Set a font size that stays readable after the re-encode (15 is a good floor), then size the grid (columns/rows) to fill the display, not the pixel bounds; oversized bounds clip instead of reflowing.
- Focus: Dock-click Terminal, `set index of window id $WIN to 1`, and confirm with a `screencapture -x` still that the right window is painted (the Claude Code window may also be Terminal).
- Typing: clipboard paste, never long `keystroke`s. Wait ~1.5s after creating the window. After each command read `get contents of window id $WIN`; if one landed wrong, redo the take from an empty prompt.
- Pacing: 10–15 seconds between steps.
- Closing: if a "Terminate" sheet appears, click it via System Events and confirm with `get id of every window`.

## Commands in a recorded terminal
- One plain command per line: no `&&`/`;`/`||`, no alias or function wrappers. A login helper (`source` + one call) is the only exception.
- Only real typed commands on screen; no `echo`'d notes. Explanation goes in the report.
- Never alter a `curl` or its output (no truncating, reshaping, silent re-runs); a raw failure is evidence. On camera, show the raw response; `jq` parsing is for scripts. If the command itself was wrong, fix it, re-record, and say so.
- Small page sizes on list endpoints.
- Never name a variable `UID` or `GID` (read-only in zsh).
- Never put a token on the command line; the title bar shows it expanded. Write it to a temp header file (`HDR=$(mktemp)`, `printf 'Authorization: Bearer %s\n' "$TOKEN" > "$HDR"`) and `curl -H @"$HDR"`.
