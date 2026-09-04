---
name: Native-token legacy migration
description: Safety rule for reconciling the old cent-based BEEP economy with Cardano smallest units.
---

Legacy BEEP cents may only migrate to native-token units when the exact configured Cardano asset unit and policy match, and every legacy monetary value maps to a whole on-chain unit. Abort the migration if either condition fails; never round or truncate balances.

**Why:** Cardano asset units are indivisible integers. Silent integer division can destroy fractional legacy value, while fuzzy or malformed asset identity can strand balances under a token that can never settle on-chain.

**How to apply:** Any future ledger migration or BEEP decimal change must validate the complete policy-plus-asset unit, check divisibility before writing, and require explicit reconciliation when old values cannot map exactly.