---
name: Ruby TLS CRL failure and fix
description: All Ruby Net::HTTP HTTPS calls fail with "unable to get certificate CRL" in this env; fix is a fresh X509 store, never VERIFY_NONE.
---

## Rule
Any Ruby `Net::HTTP` HTTPS call in this environment fails the handshake with
`OpenSSL::SSL::SSLError: certificate verify failed (unable to get certificate CRL)`
when using the default certificate store (curl works fine). Fix: give the client a
fresh `OpenSSL::X509::Store` with `set_default_paths` and keep `VERIFY_PEER` — the
app has a `SecureHttp.client(uri)` helper for exactly this.

**Why:** the environment's default OpenSSL store has CRL checking enabled, and most
hosts (Web3Forms, OpticOdds, Blockfrost) don't publish CRLs, so verification fails.
It is NOT specific to any one API. Blockfrost previously "worked" only because it
used `VERIFY_NONE` (insecure, since removed).

**How to apply:** for every outbound HTTPS call from Ruby, use the SecureHttp helper
(or replicate the fresh-store pattern). Never "fix" it with `VERIFY_NONE` — that
disables certificate verification entirely and allows MITM. This is also the known
fix to apply when wiring the OpticOdds live-odds integration.
