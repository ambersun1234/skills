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
