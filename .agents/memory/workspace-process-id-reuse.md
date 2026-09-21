---
name: Workspace process ID reuse
description: Why a resumed development workspace can falsely report that Rails is already running.
---

Persisted Rails PID files can identify unrelated processes after the workspace resumes. Do not assume that a live PID from an earlier session is still the Rails server, and never kill it solely on that basis.

**Why:** A saved server PID was reassigned to the editor language-server process. Rails refused to open its port even though no application server was running.

**How to apply:** Check the process command and listening ports when startup says a server already exists. Prefer the existing Puma configuration for development startup without relying on the Rails CLI's persisted PID check. Preserve real port-conflict detection.