---
name: Authenticated marketing captures
description: How to capture signed-in SportsBeep pages safely for public-facing mockups.
---

Use the Replit HTTPS development domain—not localhost—when automating a normal sign-in for screenshots of authenticated pages.

**Why:** The credentials can authenticate successfully over localhost, but this app’s secure session cookie is not retained over HTTP; the redirect therefore returns to the login page.

**How to apply:** Create a temporary development account, sign in through the real form over the HTTPS development domain, capture only non-sensitive screens, and delete the temporary account immediately afterward. Never add a persistent authentication-bypass route.