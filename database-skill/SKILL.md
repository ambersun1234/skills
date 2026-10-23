---
name: database-skill
description: Use BEFORE writing or changing database code or planning a migration: Mongo/SQL queries, schema/data migrations and their rollback, collections, indexes, pagination, transactions, multi-step writes, N+1 lookups, slow queries, or a global singleton DB client getter. Covers indexes, cursor pagination, uniqueness under concurrent writes, transactions/saga, expand/contract migrations, and the package-level-var stale client footgun.
---

# Database

## General
- Select only the columns you need.
- Index high-cardinality columns that queries filter or join on (e.g. user id, product id).
- Add a composite index for columns queried together (e.g. user id + product id).
- Add a partial index where queries filter on a condition (e.g. user id where `first_bought`).
- Use a transaction for multi-step writes, and roll it back if the operation fails.
- When a transaction isn't possible, use the saga pattern, with a compensating step for each write, to keep the data consistent.
- Guarantee uniqueness in the database, never only by a "check it doesn't exist, then insert" in code: two concurrent requests can both pass the check. Pick whichever fits:
  - A unique constraint/index: the default when uniqueness is on columns of one table. The second insert fails; the repository turns the driver's unique-violation error into a domain error, and the API answers it as a conflict (`400`, see `middleware-skill`).
  - The check and the write in one transaction at an isolation level that stops phantoms (Serializable in PostgreSQL; a locking read in MySQL): for uniqueness a constraint can't express (e.g. across tables). Retry on a serialization failure.
- Fetch related rows in one query to avoid N+1 queries.
- Avoid queries that force a full table scan, like `where name like '%test%'`. A prefix match (`where name like 'test%'`) is fine, because it can use the index.
- When a join isn't possible, run several queries and merge the results in the application layer.
- Default to cursor-based pagination, ordered by a unique, stable key (add the id, e.g. `_id`, as a tiebreaker), so pages never skip or repeat rows. If the API contract already defines offset/page paging, or callers must jump to an arbitrary page, follow the contract and use a deferred join (paginate on the indexed key first, then join back for the rows) so deep pages stay fast.

## Go
- Never call a global singleton getter (e.g. `GetClient()`, a DB/HTTP client getter backed by a package-level var set up during app bootstrap) inside a package-level `var` initializer, and never cache its result as a field on a package-level singleton built that way.
  - Package-level `var`s are evaluated before `main()` runs, before the app's dependency-init step sets up the real client. The global helper is still its zero value then, and a value captured into a struct field at that moment stays stale forever, even after the real client connects.
  - Default fix: don't capture it before `main`. Build the dependency in `main` after the dependency-init step and inject it into the struct that uses it, behind an interface (see `unit-test-skill`); or, where nothing injects it, construct the thin wrapper fresh inside the method that runs per request; it's cheap.
  - Cache only if profiling shows it matters. Then wire an explicit `Init()` called at boot, after the dependency-init step, not a lazy `sync.Once` hidden in a getter, which obscures when construction happens.

## Migrations
Based on the author's blog post on database migration (search the blog MCP for "database migration" for the full reasoning).
- Back up before migrating, as a last resort. Restoring a backup after the system is already upgraded can break compatibility, so it isn't the rollback plan.
- Check the migration matches the business requirement, and state its impact (is it commercially feasible, does it clash with future plans).
- Automate it (SQL, a migration tool, or a small program for complex logic); never migrate by hand.
- Make it reversible: an `up` script and a `down` script, so a rollback leaves the database clean (e.g. `down` drops the column `up` added).
- When old application code still runs during the rollout, change the schema in expand/contract steps, never a rename or drop in one step: add the new column, write to both, backfill, switch reads, and drop the old column in a later release.
- Plan for backward compatibility. When old rows lack the data the new format needs, pick the option that loses the least (backfill a default, or keep `NULL` and handle it in code), and say which.
- Guard against touching unrelated data: test with a few records locally, then on dev and staging, before production.
- Make every migration idempotent: running it twice gives the same result. Use an upsert (`INSERT ... ON CONFLICT ... DO UPDATE`), which needs a unique constraint; without one, query then write inside a transaction. For DDL, use `IF [NOT] EXISTS`.
- For a long migration, run it off-peak, or use a checkpoint to collapse old migrations. For near-zero downtime with backward-compatible data, migrate a second database in the background with Change Data Capture and cut over (blue-green). Downstream consumers of replayed events must be idempotent.
