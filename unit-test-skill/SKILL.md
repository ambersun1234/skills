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
+ name each test case as "Should <expected outcome> if/when <condition>" (e.g. "Should return true if all values are valid", "Should return an error when the user is not found") — state the expected result first, then the condition that produces it
+ the "<expected outcome>" half of the name must literally match what the test body actually asserts, not just gesture at it
+ place the unit test case file besides the implementation file, it should be in the same directory as the implementation file
+ the unit test should cover every possible code path of the function, consider every possible branch, you shouldn't skip any branch. you may assume the input data is sanitized by the caller, don't write test case that pass the invalid input data to the function
+ an edge case only belongs to the function under test if that function's own code actually branches on it
+ you should always try to use before and after hook to setup and teardown the entity

# language specific best practices
## golang
+ mock interfaces with mockery (testify template), not hand-written fakes — even in a repo that doesn't have mockery set up yet, add a `.mockery.yaml` (mirror an existing one in the codebase, e.g. `portal-api/.mockery.yaml`) rather than falling back to a hand-written fake
+ when the interface being mocked lives in the same package as its own test file, mockery's generated mock package commonly reuses the source package's name
+ always try to mock interface, if no interface is available, you should create an interface for the function to mock
+ if create an interface introduce much more heavy work, consider use gomonkey first
+ always use table-driven tests
+ table-driven tests mixing success and error cases, prefer one unconditional `require.ErrorIs(t, err, tc.expectedError)` followed by `require.Equal(t, tc.expected, got)` over manual `if tc.expectedError != nil { ... return }` branching — `errors.Is(err, nil)` is equivalent to `err == nil`
+ don't write section-divider comments in a test file to separate the tests for different functions
+ test files carry no comments at all, not even a "why" comment for a non-obvious mock/stub setup
+ mockery mocks, call them via `.On("MethodName", args...).Return(...)`
+ mockery mocks you can use `.Once()` to ensure a method is called exactly once, or `.Times(n)` to ensure it's called exactly `n` times, or `.Maybe()` to allow it to be called zero or more times
+ table-driven tests, fill in every field of every test case struct literal explicitly
+ always use keyed struct literals (`{name: "...", expected: "..."}`), never positional (`{"...", "..."}`)
+ in a table-driven test case, `want` is reserved for an expected *error* (`wantErr bool` or similar) — an expected *value* field is named `expected` or `expectedX` (e.g. `expectedProjects`, `expectedClientDBID`), never bare `want`
+ gin handlers/middleware, test them with `httptest.NewRequest`/`httptest.NewRecorder` against a minimal `gin.New()` router
+ for golang, name an interface that exists purely to seam a dependency out for mocking with a trailing `I`
