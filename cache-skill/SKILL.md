---
name: cache skill
description: describe how to write cache related code in the codebase, use when you need to add or modify cache related code or user ask to optimize the cache related code to the codebase
---

# cache best practices
the document outlines the best practices for writing cache related code in the codebase.

## when to use this skill
when you need to add or modify cache related code or user ask to optimize the cache related code to the codebase

## best practices
+ you should always try to use transaction within cache operation whenever possible to ensure data consistency, and rollback the transaction if the operation failed
+ you should separate different cache value into different database to have better maintainability, don't put all the cache value into the same database
+ you should always try to use cache eviction policy to ensure the cache value is always up to date
+ you should always try to use sorted set instead of list to store ordered data
+ you should try to use cuckoo filter when you need fast lookup if data present or not
