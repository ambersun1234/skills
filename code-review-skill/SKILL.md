---
name: code-review-skill
description: Use BEFORE writing or editing ANY source code (Go, TypeScript, Java, shell, any repo), and when reviewing a diff or PR. Baseline code style: zero comments by default, naming (no single-letter vars, singular range vars, camelCase import aliases, no ensureX), struct methods over loose funcs, explicit return-don't-mutate helpers, []*T slices, file declaration order, reuse before writing new logic.
---

# Code style and review

## General
- Clear, concise names. Never a single meaningless letter (`x`, `d`) for a variable or parameter.
- No deeply nested ifs or loops; extract functions or classes.
- Keep an abstraction layer between layers (e.g. handler → service → repository); don't put all the logic in one.
- Log errors and successes at the boundaries where they happen (see `logging-skill`).
- Give plain values their own named type, e.g. `UserId` instead of `int`, so a signature like `(int, int, int, int)` says what each argument is. In Go that is a defined type (`type UserId int`), not an alias (`type UserId = int`).
- Before writing new logic, check whether the repo already has it; if not, prefer a well-known third-party package over reinventing the wheel.
- Build on dependency injection: depend on interfaces and inject the implementation, so it can be swapped (in tests, or for another backend).
- Keep every operation explicit. A helper that decides something returns the decision (e.g. `(bool, error)`) and the caller writes it back; a helper never mutates an argument as a hidden side effect.
- These rules apply to new code. Existing code outside the task stays as is, even in a touched file; mention it and ask.

## Comments
- Default to none. Write one only when a reader can't understand the code without it (a hidden constraint, a bug workaround, a non-obvious design decision), and explain why, never what. Cut any sentence that restates the name or the body.
- Put it at the most specific block it explains, once, not as a doc comment on the whole type repeated near the block.
- Reference an issue or PR by full URL (`https://github.com/<org>/<repo>/issues/123`), never bare `#123`. GitHub-native text keeps `#123`.

## Go
- Name a range variable as the singular of the collection (`for _, group := range groups`), not `g`, `pr`, `v`.
- In a shared library, don't give a generic name to something that encodes one consumer's convention.
- Import aliases in camelCase (`authProvider`, not `authprovider`).
- A single-letter method receiver (`func (h *helper)`) is fine.
- In a file, unexported declarations first, then exported ones.
- Prefer methods on a struct holding the shared dependencies over loose package functions.
- No `ensure` prefix (`ensureProjectMembers`). Use `checkX` for a validator returning an error, or a name for what it does.
- Don't name a file after its package (`cart/cart_service.go`).
- A slice of a nested struct type is always `[]*T`, never `[]T`, in every struct field.
- A multi-line comment uses a `/* ... */` block with a leading `*` per line; a single line uses `//`.

```go
/*
 * explanation goes here, spanning
 * multiple lines.
 */
```
