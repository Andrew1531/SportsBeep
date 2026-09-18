---
name: Rails test database isolation
description: Avoid accidentally targeting PostgreSQL when running the local SQLite test suite.
---

Run local Rails tests and test database preparation with the inherited DATABASE_URL removed from that command's environment.

**Why:** Rails can merge the inherited PostgreSQL URL over the configured SQLite test database. A test run attempted PostgreSQL schema maintenance rather than using the intended local scratch database.

**How to apply:** Use a command-scoped unset, not a workspace secret change, and confirm the configured test database before any test schema preparation. Never boot the production Rails app for a read-only financial audit; startup recovery callbacks may mutate financial records.