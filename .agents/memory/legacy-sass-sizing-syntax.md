---
name: Legacy Sass sizing syntax
description: Compatibility constraints for responsive CSS sizing in the project's SassC asset pipeline.
---

Do not use modern CSS `min()`, `max()`, or `clamp()` functions in SCSS when their arguments have mixed units. Express the same bounds with `width`/`max-width` and media-query overrides.

**Why:** The pinned legacy SassC pipeline evaluates these functions as Sass math during asset compilation. Mixed units such as viewport units and pixels trigger an internal incompatible-units error and make every page using the application stylesheet return 500.

**How to apply:** For responsive UI work, compile the complete application stylesheet after introducing sizing expressions. Use ordinary CSS properties and breakpoints rather than modern sizing functions.