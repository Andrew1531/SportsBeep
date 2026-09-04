---
name: Cardano dApp architecture
description: How CIP-30 wallet verification and on-chain $BEEP transfers work; invariants to preserve
---

# Cardano dApp architecture

- Wallet connection is real CIP-30: browser extension picker → server-issued session nonce → wallet `signData` → Ruby-side CIP-8 COSE_Sign1 verification (cbor + ed25519 + blake2b + bech32 gems, all vendored via Gemfile). Legacy pasted addresses remain but are unverified; loading $BEEP requires `cardano_wallet_verified_at`.
- On-chain mode is feature-flagged: active only when BOTH `TREASURY_ADDRESS` and the canonical full `BEEP_ASSET_UNIT` (policy ID + asset-name hex) are set. Without them the legacy "virtual credit" flow runs unchanged.
- **Why the full asset unit is mandatory:** name matching is spoofable and policy-only matching can accept a different coin from the same minting policy; all money movement and on-chain balance display must use exact-unit equality.
- Transaction building/signing happens in a Node CLI (`cardano-tools/beep-tool.mjs`, Mesh SDK) shelled out from Rails — Ruby has no Cardano tx library. Treasury hot wallet key comes from `TREASURY_MNEMONIC` secret.
- **Withdrawal rule:** build/sign without charging, then persist the deterministic tx hash and debit under lock immediately before submit. Any post-hash failure remains debited and reconciles on-chain; never refund from a submit response alone. Refund only after the hash remains absent for the full confirmation window. Deposits credit only after ≥2 confirmations, idempotently under account lock with a unique tx_hash index, and inputs must come from the user's verified wallet (stake-credential match).
- Rails session cookie is `secure: true` — curl testing must go through `https://$REPLIT_DEV_DOMAIN`, not localhost.
- User wallet columns are set via `update_columns` because unrelated user validations (e.g. username presence) must not block wallet verification.

## CIP-8 CBOR envelope

CIP-8 `COSE_Sign1` signatures are wrapped in CBOR tag 18. The Ruby `cbor` gem decodes that envelope as `CBOR::Tagged`, not as the four-element array directly; accept only tag 18 and verify its value.

**Why:** Treating the decoded object as an array rejects standards-compliant `signData` output from real Cardano wallets.

**How to apply:** Any verifier or fixture for CIP-30 `signData` must encode/decode the tag-18 envelope, while rejecting untagged or differently tagged structures.
