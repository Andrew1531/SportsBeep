---
name: Native-token legacy migration
description: Safety rule for reconciling the old cent-based BEEP economy with Cardano smallest units.
---

Legacy BEEP cents may only migrate to native-token units when the exact configured Cardano asset unit and policy match, and every legacy monetary value maps to a whole on-chain unit. Abort the migration if either condition fails; never round or truncate balances.

**Why:** Cardano asset units are indivisible integers. Silent integer division can destroy fractional legacy value, while fuzzy or malformed asset identity can strand balances under a token that can never settle on-chain.

**How to apply:** Any future ledger migration or BEEP decimal change must validate the complete policy-plus-asset unit, check divisibility before writing, and require explicit reconciliation when old values cannot map exactly.

For financial reports, verify registry decimals independently of the app's approved-token settings and retain raw integer quantities in the report. Never silently edit decimals or rescale balances to make a displayed balance match expectations.

**Why:** A live treasury audit found different registry and platform decimal conventions. The owner explicitly confirmed on 2026-09-18 that SportsBeep should show BEEP as whole raw units: 1,000,000 units means 1,000,000 BEEP on the platform, not 1 BEEP. Registry metadata must not override that product convention.

**How to apply:** Keep BEEP's zero-decimal platform display, add thousands separators, and retain registry metadata in technical details only. ADA still converts lovelace using six decimals. Do not rescale balances, swap rates, or wager quantities to match registry metadata. Audit transfers and ledgers before any separately authorized denomination migration.