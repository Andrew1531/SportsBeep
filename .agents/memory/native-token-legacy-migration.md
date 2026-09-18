---
name: Native-token legacy migration
description: Safety rule for reconciling the old cent-based BEEP economy with Cardano smallest units.
---

Legacy BEEP cents may only migrate to native-token units when the exact configured Cardano asset unit and policy match, and every legacy monetary value maps to a whole on-chain unit. Abort the migration if either condition fails; never round or truncate balances.

**Why:** Cardano asset units are indivisible integers. Silent integer division can destroy fractional legacy value, while fuzzy or malformed asset identity can strand balances under a token that can never settle on-chain.

**How to apply:** Any future ledger migration or BEEP decimal change must validate the complete policy-plus-asset unit, check divisibility before writing, and require explicit reconciliation when old values cannot map exactly.

For financial reports, verify registry decimals independently of the app's approved-token settings and retain raw integer quantities in the report. Never silently edit decimals or rescale balances to make a displayed balance match expectations.

**Why:** A live treasury audit found a disagreement between the registry's decimal convention and the app's display configuration. An apparently large balance can represent a much smaller token-denominated balance; changing presentation settings can also change how future user-entered amounts are interpreted.

**How to apply:** If the two conventions disagree, report both explicitly, reconcile the intended denomination with the owner, and audit transfers and ledgers before any migration. A request to match wallet presentation authorizes registry-based treasury display, not changes to stored units, swap rates, or wager denominations.