---
name: Rails callable test doubles
description: Minitest factory stubs for callable service objects in this Rails/Ruby environment.
---

Wrap callable service doubles in a factory lambda when stubbing their constructor, and explicitly require `minitest/mock` in files that use its stubbing helpers.

**Why:** Minitest treats a replacement that responds to `call` as the stub implementation, not as a return value. Passing a service instance directly as a constructor replacement invokes the service prematurely. Depending on another test file to load the mocking extension also makes results depend on test selection.

**How to apply:** Stub constructors with a lambda returning the prepared service double. When a one-field Struct holds a response hash, pass the hash explicitly as a positional object; Ruby's keyword handling otherwise interprets its keys as Struct fields.