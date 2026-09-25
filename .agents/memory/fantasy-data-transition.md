---
name: Fantasy sample-to-live data strategy
description: User-approved approach to restore original fantasy gameplay before paid sports data is available.
---

Use supplied sports-data examples to build and test the archived original fantasy game, keeping its gameplay and the current platform UI independent of the eventual paid data provider.

**Why:** On 2026-09-25 the user explicitly chose to use the supplied code/data first and replace the data connection once a paid, working API is available. Provider access should not block sample-backed gameplay development.

**How to apply:** Isolate provider adapters behind a consistent data contract. Label historical/sample data clearly, preserve original IDs and timestamps, and keep sample play separate from real balances and payouts. Later replace the sample provider, not the original gameplay, and verify live coverage and scoring before enabling paid play.