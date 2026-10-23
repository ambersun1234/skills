---
name: logging-skill
description: Use BEFORE adding or changing any log line, logger setup, or debug output (zap, logrus, Python logging), and when an error path is written without a log. Covers library over print, levels, structured context fields (request id, user id).
---

# Logging

## General
- Log through a logging library, never print statements. Which library is set per language below.
- Make each message describe the current context.
- Attach structured context fields, such as request id, user id, processed message count.
- Give every message the right level; don't log everything at one level. `WARNING` is a problem that doesn't affect what runs next; `ERROR` is one that does.

## Go
- Use the logger the repo already uses. In a repo with none, ask the user which one (zap or logrus).

## Python
- Use the built-in `logging` library with a customized formatter; see [logger.py](references/logger.py). That example is the console handler. To also log to a file, fan out with a separate handler for it (its own formatter, e.g. without the console colors).
