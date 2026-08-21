---
name: middleware skill
description: describe how to write middleware code in the codebase, use when you need a filter or interceptor to process the request or response
---

# middleware best practices
the document outlines the best practices for writing middleware code in the codebase.

## when to use this skill
when you need a filter or interceptor to process the request or response

## best practices
+ when you have multiple data to process, you should write separate middleware to process each data
+ if you need to check data present or not, try to use cache instead of database query
+ you should fail fast if the request is invalid, don't process the request further
+ you should return 400 bad request if request is invalid

# language specific best practices
## golang
+ when a route needs more than one gatekeeping check (e.g. "caller must be a specific identity" and "both parties must already be members of X"), it's fine to run them as ordered steps inside one middleware function rather than one middleware per check, as long as each step aborts (`c.Abort()` + the right `bodies.SetXxx`) before falling through to the next
