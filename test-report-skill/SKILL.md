---
name: test-report-skill
description: Use BEFORE planning a recorded test case, reviewing or replacing a recording, or posting a test report on an issue. Covers a minimal self-contained reproduction, reviewing the whole video, the summary table, PASS/FAIL verdicts, ruling out your own mistake, one report per PR, and attaching videos with gh. Load screen-recording-skill to record.
---

# Test reports

What a recorded test case must show, and how to report it. Recording itself (screen lock, ffmpeg, terminal hygiene) is in `screen-recording-skill`. The environment (URLs, accounts, helper scripts) belongs in a project skill.

## A take is a minimal, self-contained reproduction
The test isn't "does it start at an empty prompt" but: **could a viewer, with nothing else, follow exactly these steps to the same result?**
- **Complete:** every step the result depends on is in the take, including setup (minting a token, creating the account, group or project). Prose doesn't count.
- **Minimal:** nothing else; no exploration, no second scenario.
- Typical failures: a token minted off-camera; one take attached under two cases; a take reused from another issue.
- Standing objects of the environment (seeded projects, shared accounts, fixed IDs) may be referenced. Anything the testing created is created in the take that uses it, even if an earlier case already made it.

**Check before attaching:**
- `shasum` every video; a repeated hash is a shared take.
- Review the whole video, every scene change plus a frame every 2 s, in order, at full size:

```bash
ffmpeg -i case.mp4 -vf "select='gt(scene\,0.003)+not(mod(n\,24))'" -fps_mode vfr frames/%04d.png
```

  `n,24` is one frame every 2 s at the 12 fps re-encode; adjust it if the video's frame rate differs.

  Each step must appear in order with the right output, nothing unrelated on screen, and the first frame must be this case's own start. Say in the report the full video was reviewed.
- If reproducing needs a sentence from the prose, re-record with that step included.

## The report
- Open with a `### Summary` table, one row per case: number, short description, `✅ PASS` / `❌ FAIL`, then a tally (`**5 passed, 0 failed.**`). Repeat the marker at the top of each case section.
- Verdicts are PASS or FAIL, never "PARTIAL". The one exception is `⚠️ NOT VERIFIABLE`, only when nothing the case asks for is observable here (e.g. a rollback needing a fault injected into a shared environment), with what was tried, why it's unobservable, and that no defect is implied. Never judge a whole case on a partial check: PASS needs every assertion of the case verified. If only part can be observed, split the case into sub-rows (`2a`, `2b`): the observed part PASS/FAIL, the rest `⚠️ NOT VERIFIABLE`, and count NOT VERIFIABLE separately in the tally.
- **Rule out your own mistake before FAIL.** Read the implementation and the API docs. Usual false alarms: a named sentinel (e.g. a constant `NoLimit = -1` makes `size=-1` mean "no limit"), and a field the issue body names but the OpenAPI source no longer has (the issue is stale; report a follow-up).
- If the test command was wrong, fix it and re-record; don't explain a wrong recording away.
- Explain any number on screen that looks wrong, even when it's not a defect, after chasing its root cause.
- **Rule out the environment** (flapping nodes, a gateway `502`/`503`, a deployment swapped out for debugging) before calling a bug. If someone's in-progress debugging is in the way, tell the user and stop; never roll it back.
- **A UI guard hiding a backend fix** isn't a FAIL: in the same take, do the blocked step through the API in a Terminal, continue in the UI, and report the frontend gap separately with a proposed fix.

## One report per PR
- Keep one report comment per PR and session: delete your own previous one first (`gh api -X DELETE repos/<owner>/<repo>/issues/comments/<comment_id>`).
- Never delete or overwrite a report you didn't post or that covers another PR; add yours alongside, headed with the PR and build. Keep local files and videos until the issue closes.

## Attaching videos with `gh`
- `gh issue comment --attach <file>`, bare path (videos reject `<file>#<alt>`).
- Place each with `![caption](./case1.mp4)` in the body; unreferenced files go to the end. Caption each with the automated test it corresponds to.
- Assets can't be added to an existing comment: to replace a video, delete and repost. Text-only fixes can be a `PATCH`.
