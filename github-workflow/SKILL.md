---
name: github-workflow
description: Use BEFORE any GitHub write: pushing, opening a PR, replying to review comments, or when told to 'hold' a PR. Covers checking CI after every push and what to do when it fails, how to answer review comments (👀 = accepted and fixed, a plain reply = disagree and discuss), never resolving review threads, and 'hold'. Also load the company workflow skill for the repo's org if one exists.
---

# GitHub workflow

Also load the company workflow skill for the repo's org, if one exists (company skills are named `<company>-*`, e.g. `<company>-github-workflow`); it wins on conflicts.

## Check CI after every push
- After every push, check the CI run and confirm it passes; a push isn't done until it does.
- If CI fails, diagnose and fix it, then show the user the fix and wait for their OK before pushing. Never re-push just to see if it passes, and never skip or bypass the failing check.
- Exception: a purely cosmetic failure on a PR the user already approved. If the fix comes from the repo's own formatter/linter and touches nothing a reader would call logic (a `prettier --write` rewrap, a `golangci-lint fmt` diff, an import reorder), push it without asking and say afterwards what it was. A failing test, a build error, or a lint rule needing a real code change still goes back to the user first.

## Answer every review comment
After pushing changes for a review, give every inline comment exactly one of:
- **👀 (`eyes`) reaction = accepted and fixed.** Only when you agree and the fix is pushed (in this push or an earlier one). If you agree but haven't fixed it yet, fix and push first, then react. No text. `gh api repos/<owner>/<repo>/pulls/comments/<comment_id>/reactions -f content=eyes`
- **A plain text reply, no emoji = not accepted, let's discuss.** When you disagree or anything is still open. Say what you think and why. `gh api repos/<owner>/<repo>/pulls/<n>/comments -F in_reply_to=<comment_id> -f body="..."` (`-F`, since the id is numeric).

Review-body prose not tied to a line gets one consolidated top-level PR comment.

## Never resolve a review conversation
Reply or react, but never resolve the thread (button or `resolveReviewThread`). Resolving is the reviewer's call.

## "Hold" = open it and stop
On "hold": open/push the PR, then don't merge it and don't add a merge-triggering label until told to merge. CI still has to pass.
