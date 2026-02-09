---
name: database skill
description: describe how to write database related code in the codebase, use when you need to add or modify database related code or user ask to optimize to the codebase
---

# database best practices
the document outlines the best practices for writing database related code in the codebase.

## when to use this skill
when you need to add or modify database related code or user ask to optimize the database related code to the codebase

## best practices
+ you should always try to select only necessary data from the database, don't select all the data from the database
+ if you encounter performance issue, you should check the table definition, index, query plan ... etc. to optimize the query
+ you should always try to set up an index for the column that has a high cardinality, for example, user id, product id ... etc.
+ you should always try to set up a composite index for the column that is frequently used together, for example, user id and product id ... etc.
+ you should always try to set up a partial index for the column that is frequently used together, for example, user id and first_bought(bool) ... etc.
+ you should always try to use transaction whenever possible to ensure data consistency, and rollback the transaction if the operation failed
+ if transaction is not applicable, you should deploy saga pattern to ensure data consistency and proper compensate mechanism
+ you should try to select multiple rows at once whenever possible to prevent N+1 query issue
+ you should avoid full table scan when query the data, like `where name like '%test%'` ... etc.(however `where name like 'test%'` is acceptable because it's a prefix scan)
+ for any fast query, you should always try to use database addons whenever possible, like postgresql gin and gist index, custom operator and query function ... etc.
+ if database join is not applicable, you should use multiple queries to get the data and merge it in the application layer
+ for pagination query, always use cursor based pagination whenever possible, don't use offset based pagination
