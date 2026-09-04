---
name: Sprockets cache refresh
description: How to avoid stale compiled styles when validating substantial SCSS changes.
---

When a substantial SCSS change does not appear after an asset clobber and Rails restart, clear the Sprockets temporary cache as well as generated public assets, then compile in a fresh process.

**Why:** This project’s pinned Sprockets/SassC pipeline can retain an older processed stylesheet under `tmp/cache` after `assets:clobber`. The HTML may continue linking to an unchanged digest and screenshots can show obsolete rules even though the source is correct.

**How to apply:** Run the cache-clear and asset-clobber tasks together before recompiling. Confirm the served stylesheet has a new digest and contains a distinctive new selector before evaluating the browser result.