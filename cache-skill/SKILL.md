---
name: cache-skill
description: Use BEFORE writing or changing any cache code: Redis/KVS reads and writes, cache keys, TTL/eviction, invalidation, sorted sets, membership filters, or when asked to speed something up with a cache. Covers transactions and compensation, separating value kinds, TTL plus eviction policy, sorted sets for ordered data, cuckoo filters for membership.
---

# Cache

## General
- Wrap operations that must change together (e.g. a value and its index) in a transaction: `WATCH` + `MULTI`/`EXEC` (or a Lua script). Before `EXEC` you can abort (`DISCARD`, or a changed watched key aborts it). After `EXEC`, a failed command does not undo the others, so compensate explicitly.
- Keep different kinds of values apart, so each can be inspected, flushed and tuned on its own: a separate logical DB per kind (`SELECT n`), or a key prefix per kind where only DB 0 exists.
- Give keys a TTL in most cases, so a value can't outlive the data it caches. Data that is meant to live on (e.g. a permanent leaderboard) is the exception. Also invalidate the key when the source changes: write the source first, then delete the key (don't update it in place). When another service owns the data, invalidate from its change events (see `message-queue-skill`), or accept the TTL as the staleness bound and say so.
- Set a `maxmemory` eviction policy, so a full cache evicts instead of rejecting writes. If the same instance also holds data that must never be evicted (e.g. a permanent leaderboard with no TTL), use a `volatile-*` policy, which only evicts keys that have a TTL, or keep that data in a separate instance.
- Store data you read back in order or by range (leaderboards, time-ordered items) in a sorted set, not a list. A list is fine for a plain FIFO queue.
- For a fast "have we seen this?" check over a large set, where a rare false positive is acceptable, use a cuckoo filter rather than a full set; it supports deletes, unlike a Bloom filter. It needs the RedisBloom module, so check it's available first.
