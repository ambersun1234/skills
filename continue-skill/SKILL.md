---
name: continue-skill
description: Use when the user asks to finish a long-running task end to end, or just says "continue" ("continue", "繼續", "finish it", "keep going until done", "complete all of it", a multi-step batch, a sweep over many items, a migration, a full test run plus fixes). Covers working through to completion without stopping for check-ins, tracking what's left, waiting on background work instead of ending the turn, and the few real reasons to stop.
---

# Continue until done

When the user asks to complete a long-running task, keep working until it is actually done.

Don't end the turn after one step to report progress.

Don't ask "should I continue?" or "want me to do the rest?".

The request to complete it is already the permission to continue.

## Continue mode (Stop hook)
- The `continue-mode.sh` hook turns continue mode on when the prompt says continue, 繼續, 做完, keep going and similar. Any other prompt turns it off.
- While it is on, the `continue-stop.sh` Stop hook blocks you from ending the turn, up to 20 times.
- The marker is `~/.claude/state/continue/$CLAUDE_CODE_SESSION_ID`.
- When the user asks for a long task in other words, turn it on yourself: `mkdir -p ~/.claude/state/continue && echo 0 > ~/.claude/state/continue/$CLAUDE_CODE_SESSION_ID`.
- Before you end the turn for one of the reasons in "When to stop", remove the marker first: `rm -f ~/.claude/state/continue/$CLAUDE_CODE_SESSION_ID`.

## Before starting
- Write down the full scope: every item, step or file the task covers.
- Keep that list as a todo list, and update it as each piece finishes.
- Decide what "done" means up front: tests pass, every item is handled, the build is green.

## While working
- After each step, check the list and go straight to the next open item.
- A progress note is fine, but put it in the same turn as the next tool call. It never replaces the next call.
- When one item fails, note it, and move on to the other items if they don't depend on it. Come back to the failure after.
- When you hit a small decision with an obvious default, take the default, note it, and keep going.
- When the context grows long, keep going. The conversation gets summarized; you don't need to wrap up early.

## Waiting on background work
- A long build, a test suite or a CI run is not a reason to end the work.
- Run it in the background and do other open items while it runs.
- When nothing else is left, wait for it with the harness's own wait mechanism (a background notification, Monitor, ScheduleWakeup). Don't end the turn and hand the wait to the user.

## When to stop
Stop only for one of these:
- The task is done, and you checked it against the "done" definition.
- A real decision only the user can make: a fork in scope or design with no sensible default.
- An action that needs explicit approval under other rules: an outward-facing or hard-to-reverse step (push, merge, deleting data, a mutating command on a live system).
- A blocker you can't get past yourself: missing credentials, a signing failure, a tool that keeps failing after a few different attempts.

When you stop for a blocker, finish every other item that doesn't depend on it first.

Then stop once, and ask everything at the same time.

## Finishing
- Re-check the todo list: nothing left open or silently skipped.
- Report what was done, what was skipped and why, and anything still failing, with the real output.
- Don't claim done for an item you didn't verify.
