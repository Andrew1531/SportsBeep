---
name: BEEP wallet and game accounting
description: Preserve balance and ledger invariants without confusing historical play-credit behavior with real on-chain flows.
---

External wallet holdings and wagerable game balances are distinct. Do not automatically mirror one into the other or add legacy cent amounts to native-token raw units.

**Why:** Earlier versions used a non-custodial, holdings-gated play-credit model. The project subsequently added real on-chain transfer paths. Old marketing copy and historical decisions are not sufficient evidence of the current custody model.

**How to apply:** Inspect the current transfer code, configured asset identity, approved-token decimals, and actual ledger before describing deposits, withdrawals, or liabilities. Treat historical play-credit behavior as history, not a requirement to disable real transfers.

Every financial mutation must lock the relevant account/wager, recheck bounds inside the lock, and record the corresponding ledger entry in the same transaction.

**Why:** Concurrent settlement can otherwise double-credit winnings, and balances changed without transaction records cannot be reconciled. A wallet UI balance alone is not proof of solvency.

**How to apply:** Preserve idempotent settlement and distinguish confirmed transfers, unresolved submissions, spendable balances, and potential wager payouts. Follow the on-chain withdrawal safety rule in the Cardano architecture memory; never refund solely because a submission response failed.