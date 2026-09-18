# Dedicated admin hostname

The confirmed administrative hostname is `admin.sportsbeep.com`. It has **not**
been published and this change does not create or alter DNS records or
environment variables.

## Publishing setup

1. In Replit Publishing, open **Domains** and add
   `admin.sportsbeep.com`.
2. Replit will display platform-generated A and/or TXT records for that
   publishing configuration. Copy those exact records to the DNS provider.
   Never guess, reuse, or hard-code DNS record values.
3. Wait for Replit to report that the domain is verified and confirm the
   dedicated hostname reaches the intended deployment.
4. Only after verification, set the nonsecret deployment environment variable
   `ADMIN_HOST=admin.sportsbeep.com` and redeploy.

An empty or absent `ADMIN_HOST` preserves legacy behavior. In particular, it
does not enforce the production restriction on admin paths at ordinary hosts.

## Middleware registration

`AdminHostRouter` is registered in `config/application.rb` as the outermost
Rack wrapper, before crawler headers and authentication middleware. Its
constructor contract is:

```ruby
AdminHostRouter.new(
  app,
  admin_host: ENV.fetch('ADMIN_HOST', ''),
  production: Rails.env.production?,
  login_alias: true
)
```

The constructor accepts the downstream Rack app plus:

- `admin_host:` — defaults to `ENV['ADMIN_HOST']`, with an empty value disabling
  dedicated-host routing.
- `production:` — defaults from `RAILS_ENV`.
- `login_alias:` — defaults to `true`; permits GET/POST `/login` as an alias for
  `/administrators/login` on the dedicated hostname.

Outermost placement ensures host/path classification occurs before downstream
middleware can mutate the Rack environment and ensures crawler middleware
cannot replace the dedicated-host protection headers.

Host selection uses the lowercase `Host` value without a numeric request port
and requires an exact match. It deliberately does not trust
`X-Forwarded-Host`. Before classification, paths are safely normalized for
repeated slashes and percent encoding; malformed encodings receive a generic
404 rather than reaching Rails.

## Behavior and security boundary

When configured in production, `/admin` and `/administrators` paths are
generic 404 responses on every non-admin hostname. There are no redirects to
the private hostname. On the dedicated hostname, `/` opens
`/admin/financials`; only administrative paths, assets, the favicon, and the
dedicated disallow-all `robots.txt` are exposed. Public pages, APIs,
`llms.txt`, and sitemaps return a generic 404.

Every dedicated-host response is marked:

```text
X-Robots-Tag: noindex, nofollow, noarchive, nosnippet
Cache-Control: private, no-store
```

These headers and hostname restrictions complement admin authentication; they
are not a substitute for it. The middleware does not authenticate users,
bypass authorization, or read/change sessions and cookies.

Before launch, independently verify the deployed session-store configuration
and browser cookie attributes provide the intended secure host-only isolation
(including `Secure`, and no parent-domain `Domain` attribute). Do not assume
that hostname routing alone isolates an existing session cookie.