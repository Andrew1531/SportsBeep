# Crawler discovery maintenance

`robots.txt` is advisory: only cooperative crawlers obey it. Authentication and authorization, not crawler rules, protect private pages and account data.

`llms.txt` follows an emerging convention for giving automated systems a curated site summary. Its presence does not guarantee indexing, ranking, citation, or any SEO result. Keep its descriptions factual, distinguish current features from roadmap material, and link only to intentionally public pages.

The sitemap and crawler policy use a fixed, verified production origin. Before changing `CrawlerPolicy::ORIGIN`, verify the deployed production URL rather than copying a preview or unverified custom domain. Update the public-path allowlist deliberately when public pages change. These files describe discovery behavior only; they do not publish the application or make private routes public.