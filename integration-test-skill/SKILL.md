---
name: integration-test-skill
description: Use BEFORE writing, editing or running integration tests: -tags integration, an integration tests/ package, dockertest, real dependency containers (database, cache, queue), or any feature work (features need both unit and integration tests). Covers one success case (a failure case optional), one test per route or consumer, seeding, value-level before/after asserts, no pinned host ports (inject the address); Go: table-driven, handler-direct tests, -count=1, orphaned-container footguns.
---

# Integration tests

## General
- Test one feature's scope only.
- Use the real entities (database, KVS, message queue), in containers. A third-party service with no container (a payment SaaS, an external API) is mocked instead. Containers: one per test, or one shared set torn down at the end. A shared set means every case cleans up after itself (roll back, delete its keys).
- Never pin a container to a fixed host port. Let the runtime pick a free one and inject the address into the code under test (a config field, a constructor argument, a swappable client), so suites can run side by side. A hardcoded port allows one run per machine, and an interrupted run blocks the next.
- One success case per feature. A failure case isn't required; add at most one, and never one a middleware already catches (that belongs to the middleware's unit tests). A failure only the real database can produce (e.g. a unique-constraint violation under concurrent requests) is an integration-only behaviour, not a middleware one. Add more cases only for behaviour that only an integration test can reach, e.g. cursor-based pagination, sorting or filtering done by the database.
- One test per entry point: an API route (method + path), or a consumer's queue/topic; every case through it lives in it. A behaviour spanning several routes adds a case to each route's test, never a feature-named test mixing routes.
- Seed realistic data that matches the business logic, directly into the store, never by running another feature.
- Use before/after hooks for setup and teardown.
- Avoid unreliable inputs such as the current time.
- To test a handler's own logic against a real system, call the handler directly instead of the full route; the middleware chain is covered by its own unit tests (see `middleware-skill`).
- Assert before/after state by the actual stored or sent value, not a call count or existence check. For a test double that records calls, assert the recorded argument, not how often it was called.

## Go
- Run the entities with dockertest; read the port from `resource.GetHostPort(...)`, never a fixed `PortBindings`.
- Table-driven: every case is a row in one table, never one function per case. One test function per route.
- Call a handler directly with a hand-built `gin.CreateTestContext`, setting the context keys a middleware would (e.g. the resolved user). Keep test scaffolding out of the middlewares package.
- Assert with `require.Equal` on the real struct/document, not `require.Len(calls, N)` or `require.NotNil`.
- Footgun: a "missing method" or missing `mocks` package error usually means stale or ungenerated mocks (gitignored output; see the repo's `generate-mock` task and `.mockery.yaml`), not broken code. CI regenerates them every run, which is why it only shows locally.
- Footgun: an interrupted dockertest run skips `t.Cleanup` and leaves its containers up. Before re-running, check no `go test` is alive (`pgrep -fl 'go test'`), then `docker rm -f` the orphans (unnamed, no owner). Never remove another live run's containers.
- Footgun: `go test` caches a passing run (`ok ... (cached)`) and starts no container. Pass `-count=1` whenever a fresh run is needed (pre-merge, after an interruption).
