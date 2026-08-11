---
name: ERB auto-escaping inside script tags
description: Rails <%= %> HTML-escapes output even inside <script>, silently killing the whole JS block
---

Rails auto-escapes all `<%= %>` output, including inside `<script>` blocks. `<%= something.to_json %>` renders `&quot;...&quot;`, which is a JS SyntaxError that kills the ENTIRE script block — every function in it becomes undefined, and onclick handlers fail with "X is not defined" with no server-side symptom.

**Why:** This broke the wallet Load button: `var KEY = <%= name.to_json %>` rendered as `&quot;vespr&quot;`, the whole deposit script died, and clicks did nothing for a full session before diagnosis.

**How to apply:** Any Ruby value embedded in inline JS must use `.to_json.html_safe` (or `raw`/`j`). `node --check` on the raw ERB won't catch this — the bug only exists in the *rendered* output. When "function is not defined" appears for a function that clearly exists in the template, suspect an escaped ERB interpolation earlier in the same script block.
