---
name: message-queue-skill
description: Use BEFORE writing or changing message queue code: producers, consumers, workers, RabbitMQ/Kafka/NATS, job handlers, ack/nack, offset commits, retries. Covers manual ack after processing, idempotent consumers, bounded retry with backoff, dead-letter queues.
---

# Message queue

## General
- Ack manually, only after the message is fully processed, so a crash mid-processing redelivers it instead of losing it. In Kafka, "ack" means committing the offset; turn off auto-commit.
- Manual ack means at-least-once delivery: make every consumer idempotent, so a redelivered message has no extra effect (dedupe on a message id, or make the write itself idempotent).
- Retry failed messages in the application layer, with a bounded number of attempts and backoff. After the last attempt, publish the message to a dead-letter queue (in Kafka, a dead-letter topic), wait for the broker to confirm it, log it, and only then ack. If the dead-letter publish fails, don't ack; let the message be redelivered. Never retry forever or drop it silently.
- In Kafka, retrying in place blocks the whole partition. For long backoffs, publish to a retry topic instead, carrying the attempt count in a header. Commit the original offset only after the broker confirms the retry publish; if it fails, don't commit.
