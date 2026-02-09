---
name: logging best practice skill
description: describe how to do the logging in the codebase, use when you need to add logger to the codebase
---

# logging best practices
the document outlines the best practices for logging in the codebase.

## when to use this skill
when you need to add logger to the codebase, when you need to debug the codebase, when you need to add logging to the codebase

## best practices
+ always try to use third party logging library whenever possible, then use the built-in logging library, don't use print statement to log the message
+ you should always log the message with proper logging message, detailed describe the current context of the code
+ you should always log the additional information along with the message, like the request id, user id, processed message count ... etc.
+ make sure every log message have a proper logging level, don't use the same logging level for all the messages
+ for golang, use zap logger, logrus
+ for python, use the built-in logging library with customized formatter, please check [logger.py](references/logger.py)
