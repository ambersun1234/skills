---
name: unit test skill
description: describe how to write unit tests or general tests for the codebase, use when you need to add or modify unit tests to the codebase
---

# unit test best practices
the document outlines the best practices for writing unit tests for the codebase.

## when to use this skill
when you need to add or modify unit tests to the codebase

## best practices
+ an unit test should focus on a function scope only, don't cover the logic that is beyond the function scope
+ if there's another sub function call inside the function, you should mock the sub function call and test the function logic
+ if you found out that the function didn't have proper abstraction layer, you should refactor first
+ if the function depend on the input data other function produce, you shouldn't call the other function to produce the input data, you should construct the input data on it's own
+ for the test data, you should always use fixed data, don't use random data to ensure we can easily reproduce the test case
+ for test data that are not crucial to the test case, for example, the id of the seeding data(and are not required to do the validation), random data is acceptable, but you should always have a fixed data for the test case
+ if you need to validate against constant or enum value, just use the constant or enum value to compare directly
+ to validate constant or enum value, write another test case to ensure their value is correct
+ the test case should named properly, the name should be clear and concise
+ the test case should always failed fast, don't wait until all test case are executed
+ place the unit test case file besides the implementation file, it should be in the same directory as the implementation file
+ the unit test should cover every possible code path of the function, consider every possible branch, you shouldn't skip any branch. you may assume the input data is sanitized by the caller, don't write test case that pass the invalid input data to the function
+ you should always try to use before and after hook to setup and teardown the entity
