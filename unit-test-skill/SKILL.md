---
name: unit-test-skill
description: Use BEFORE writing, editing or running unit tests (*_test.go, *.test.ts, JUnit), adding a test case, mocking (mockery, gomonkey), or fixing any bug (bug fixes need a regression case). Covers 'Should <outcome> if <condition>' naming, fixed test data, full branch coverage; Go: table-driven tests, keyed literals, expected/wantErr fields, no comments in tests, go test -gcflags=all=-l; Java: parameterized tests.
---

# Unit tests

## General
- Test one function's scope only. Mock its external dependencies (other packages, third-party code): whatever can be mocked, mock.
- Mock through DI: swap the dependency's implementation. If the function has no seam for that, add one (see Go below); if that means a large refactor beyond the dependency being mocked, point it out and ask first.
- Build input data in the test itself; don't call another function to produce it.
- Use fixed test data so a case always reproduces. Random values are fine only for fields the test doesn't check (e.g. a seeded record's id).
- Compare against a constant or enum directly; check the constant's own value in a separate case.
- Name cases "Should <expected outcome> if/when <condition>" (e.g. "Should return an error when the user is not found"). The outcome half must match what the body actually asserts.
- Cover every branch of the function's own logic. Functions run layer by layer: invalid input an outer layer already rejects isn't retested in the inner one. An edge case belongs to a function only if its own code branches on it.
- Use before/after hooks for setup and teardown.

## Go
- Put the test file next to the implementation, in the same directory.
- Always table-driven: named cases through one shared body, never one test function per case, even with a single case today. Cases asserting the same shape share a table.
- Fill in every field of every case, with keyed literals (`{name: "...", expected: "..."}`), never positional.
- `want` is only for an expected error (`wantErr bool`). An expected value is `expected` / `expectedX` (e.g. `expectedOrders`).
- Mixing success and error cases: one unconditional `require.ErrorIs(t, err, tc.expectedError)` then `require.Equal(t, tc.expected, got)`, not `if tc.expectedError != nil { ... return }`. `errors.Is(err, nil)` equals `err == nil`.
- When a case only cares that the call fails, use `wantErr bool` and `require.Equal(t, tc.wantErr, err != nil)`, not `EqualError`/`ErrorContains` on the text, which churns whenever upstream wording changes. Assert the exact message only when formatting it is the behaviour under test.
- Mock interfaces with mockery (testify template), never hand-written fakes (gomonkey patching, below, is a separate last resort, not a fake). In a repo without mockery, add a `.mockery.yaml` (mirror an existing one if there is one).
  - Mocks are usually gitignored, so a fresh worktree fails with "no required module provides package .../mocks". Run the repo's mock task (e.g. `task generate-mock`); never copy `mocks/` from another checkout, it may be stale.
  - A mock of an interface in the test's own package usually reuses that package's name.
  - `.On("Method", args...).Return(...)`; `.Once()`, `.Times(n)` or `.Maybe()` (zero or more) to pin call counts.
- Mock through an interface; if there is none, create one, named with a trailing `I`.
  - Every implementation you own goes behind an interface listing its whole exported method set, not just what this caller uses. Switch every injection point of that dependency (struct fields, package-level vars) to it; that is part of the task, not an unrelated cleanup.
  - For third-party code, mock only the parts you actually use.
  - No narrow per-caller interface plus a one-method adapter wrapping a package function (e.g. `ConfigReaderI{GetValue}` + an `envConfig{}` adapter). Turn the functions into methods on a struct with one full interface (see the dependency-inversion section of the https://ambersuncreates.com devops unit-test post).
  - Only when something can't be abstracted behind an interface (a package function you don't own, a hard-wired package-level var), patch it with gomonkey or a swappable package-level var instead.
- Footgun: with gomonkey, run with inlining off, `go test -gcflags="all=-l" ./...` (see the repo's unit-test task). A bare `go test ./...` leaves some patches unapplied, and unrelated packages panic (e.g. on a nil client); it looks like a base-branch failure, but CI passes with the flag.
- Never assert (`require.*`/`assert.*`/`reflect.DeepEqual`) inside `t.Cleanup`; it is for teardown only. Assert in the test body or inside the mock closure. Under gomonkey, a heavy reflect call deferred into `t.Cleanup` can also crash the runtime (`fatal error: invalid pointer found on stack`).
- No comments in test files at all: no section dividers, not even a "why" for a tricky mock. Compiler directives (`//go:build`) aren't comments and stay.
- Test gin handlers/middleware with `httptest.NewRequest`/`httptest.NewRecorder` on a minimal `gin.New()` router.
- One `X_test.go` per `X.go`, never split across several test files. Split the test file only when the source file splits.

## Java
- Follow the Maven/Gradle layout (`src/test/java`, mirroring the main package).
- Use JUnit5 `@ParameterizedTest` + `@MethodSource` for cases that vary only their input, not one `@Test` per input.
