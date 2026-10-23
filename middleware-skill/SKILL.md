---
name: middleware-skill
description: Use BEFORE writing or changing HTTP middleware (gin or any framework), route Middlewares lists, request validation/binding, auth/role/ownership checks, or deciding whether a check belongs in middleware or the handler. Covers one check per middleware, ShouldBindBodyWith everywhere, 400/401/403 fail-fast, gatekeeping vs business logic, DI for external calls (func var only as fallback).
---

# Middleware

## General
- One check per middleware; chain several instead of combining them as steps in one function.
- To check whether data exists, prefer a cache lookup over a database query, when a cache exists and is kept in sync with writes; a stale cache gives wrong answers.
- An existence check in middleware only fails fast; it can't stop two concurrent requests from both passing. The database still guarantees uniqueness (a unique constraint, or a transaction; see `database-skill`).
- Fail fast. Invalid input `400`, a conflict with existing state (e.g. already exists) `400`, no session `401`, not allowed `403`.
- **Gatekeeping goes in middleware, the action's own logic goes in the handler.**
  - Middleware: reusable, structural checks deciding whether the request may proceed at all (auth, ownership, request shape).
  - Handler: a check that is the point of the action, e.g. a transfer endpoint's "does the source account have enough balance", or any "confirm X against a live system as part of doing the thing".
  - Rule of thumb: if the handler would still do something complete without the check, it's gatekeeping. If the check is inseparable from what the handler accomplishes, it's business logic.

## Go (gin)
- On a failed check, stop the chain with `c.AbortWithStatusJSON(...)` and return; writing a response without aborting still runs the handlers behind it.
- Chain the checks in the route's `Middlewares` list, e.g. `ValidateCreateXRequest()` (bind) + `ValidateXRole()` + `ValidateXNotExists()`.
- Every middleware and handler that needs the JSON body calls `c.ShouldBindBodyWith(&req, binding.JSON)` itself, never `c.ShouldBindJSON`. The body stream drains once; `ShouldBindJSON` consumes it and later binds get EOF, while `ShouldBindBodyWith` caches the bytes on the context.
  - **Don't "clean this up" by binding once and passing the struct along** (`c.Set`, a context key, a getter around `c.Get`). Standing preference, don't ask again: each site binds independently, even three times in a row.
  - A shared bind helper (`Bind`/`ParseBody`) must use `ShouldBindBodyWith` for its JSON step, so calling it from every site stays safe.
- Call an external system (an identity provider, another service) through an injected interface, so unit tests swap in a mock and integration tests a client pointed at a real dockertest instance.
- Only when the dependency can't be put behind an interface, fall back to a swappable package-level func var initialized from the real implementation (`var SendInvoice = billing.SendInvoice`). Export it only when code outside the package (e.g. `tests/`) must override it.
