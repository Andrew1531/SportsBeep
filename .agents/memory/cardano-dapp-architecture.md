---
name: Cardano dApp architecture
description: How CIP-30 wallet verification and on-chain $BEEP transfers work; invariants to preserve
---

# Cardano dApp architecture

- Wallet connection is real CIP-30: browser extension picker → server-issued session nonce → wallet `signData` → Ruby-side CIP-8 COSE_Sign1 verification (cbor + ed25519 + blake2b + bech32 gems, all vendored via Gemfile). Legacy pasted addresses remain but are unverified; loading $BEEP requires `cardano_wallet_verified_at`.
- On-chain mode is feature-flagged: active only when BOTH `TREASURY_ADDRESS` and `BEEP_POLICY_ID` env vars are set. Without them the legacy "virtual credit" flow runs unchanged.
- **Why BEEP_POLICY_ID is mandatory in on-chain mode:** fuzzy asset-name matching ("BEEP" substring) is spoofable by look-alike tokens; all money-movement paths must match the policy ID strictly. The fuzzy fallback survives only in the legacy read-only balance display.
- Transaction building/signing happens in a Node CLI (`cardano-tools/beep-tool.mjs`, Mesh SDK) shelled out from Rails — Ruby has no Cardano tx library. Treasury hot wallet key comes from `TREASURY_MNEMONIC` secret.
- **Withdrawal rule:** debit under lock first, then payout. If the payout fails at the *submit* stage the tx may still have landed — the transfer is marked `unknown` and NEVER auto-refunded; only pre-submit (build/sign) failures refund. Deposits credit only after ≥2 confirmations, idempotently under account lock with a unique tx_hash index, and inputs must come from the user's verified wallet (stake-credential match).
- Rails session cookie is `secure: true` — curl testing must go through `https://$REPLIT_DEV_DOMAIN`, not localhost.
- User wallet columns are set via `update_columns` because unrelated user validations (e.g. username presence) must not block wallet verification.
