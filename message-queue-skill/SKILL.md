---
name: message queue skill
description: describe how to write message queue related code in the codebase, use when you need to add or modify message queue related code or user ask to optimize the message queue related code to the codebase
---

# message queue best practices
the document outlines the best practices for writing message queue related code in the codebase.

## when to use this skill
when you need to add or modify message queue related code or user ask to optimize the message queue related code to the codebase

## best practices
+ you should always manual ack the message to prevent message loss
+ you should always add retry mechanism to handle the message that failed to process in application layer
