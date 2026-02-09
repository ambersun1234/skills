---
name: integration test skill
description: describe how to write integration tests or general tests for the codebase, use when you need to add or modify integration tests to the codebase
---

# integration test best practices
the document outlines the best practices for writing integration tests for the codebase.

## when to use this skill
when you need to add or modify integration tests to the codebase

## best practices
+ an integration test should focus on a feature scope only, don't cover the logic that is beyond the feature scope
+ the integration test should use the real entity, for example, real database, kvs, message queue ... etc.
+ you should use dockertest for each integration test or setup it once and teardown it after the test case is executed
+ if you setup the entity just once, make sure every test case should clean up the entity after the test case is executed(rollback the transaction, delete the data inside kvs ... etc.)
+ the test case of integration test should contain only 2 cases, success and failure, you shouldn't write test case that beyond these 2 cases unless certain situation
+ for feature that the core logic computation lies in database layer, you should write test case more than 2, like pagination, sorting, filtering ... etc.
+ the seeding data should filled with real data, it should align with the real business logic
+ you should always try to use before and after hook to setup and teardown the entity
+ you should avoid to test the code with unreliable entity, for example, time
+ you shouldn't setup the test entity with another feature, instead, you should seed the database, kvs ... etc. directly with the test data
