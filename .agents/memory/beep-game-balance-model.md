---
name: $BEEP wallet ↔ game balance accounting
description: How on-chain $BEEP relates to wagerable game balance, and the invariants that must hold.
---

# $BEEP game balance model

Only the **game balance** (`accounts.balance_cents`) is wagerable in the sportsbook/fantasy.
The connected Cardano wallet's on-chain $BEEP is read-only (via Blockfrost) and is NOT
automatically wagerable. Users explicitly move $BEEP in/out with Load and Withdraw.

`accounts.beep_loaded_cents` tracks how much on-chain $BEEP the user has moved into the
game. Invariants:
- **Available to load** = `max(0, on_chain_cents - beep_loaded_cents)` — caps loads at real holdings.
- **Withdrawable** = `min(balance_cents, beep_loaded_cents)` — you can only pull back wallet-loaded
  $BEEP, never winnings/promo credit.
- Load: `balance_cents += X`, `beep_loaded_cents += X`. Withdraw reverses (loaded floored at 0).

**Why:** the old `sync_beep` mirrored on-chain → balance with no per-amount control and never
tracked what came from the wallet, so it conflated winnings with loaded funds and let balance
drift from holdings. It was removed in favor of load/withdraw.

**How to apply:** every monetary mutation (load, withdraw, wager settle/credit) must run inside
`account.with_lock` (and `wager.with_lock` for settlement) and **re-check bounds inside the lock** —
the pre-lock check is only for UX. Use `next` (not `return`) to bail out of a `with_lock` block and
set an `error` local; flash it after the block. Settlement re-checks `open?` inside the wager lock
to prevent double payouts.

## Audit trail: every balance change must create a Transaction ledger row
All `accounts.balance_cents` mutations must create a `Transaction` (subclass) record in the same
DB transaction, so the ledger is complete/auditable. Covered paths: load/remove play credit
(AdjustmentTransaction), wager debit + win/push payout (AdjustmentTransaction via
`debit_user_account!`/`credit_account!`), fantasy contest entry fee (ContestEntryFeeTransaction).
**Why:** fantasy entry historically used `update_columns` which silently moved money with no ledger
row — a compliance/audit gap. **How to apply:** never use `update_columns`/`update_column` to change
a balance; use `update!` inside `with_lock` and create the matching Transaction. Create the subclass
directly with `.create!` (negative `amount_cents` for debits) — do NOT call `commit!` (that hits the
GL[:...] general-ledger path, deliberately bypassed for beta). The wallet HISTORY tab + `/transactions`
read `account.transactions`. NOTE: the wallet "SWAP" tab is a UI mockup with no backend/route — it
executes nothing, so there's nothing to record.

## Custody model (decided for beta): PLAY-BUDGET, non-custodial
The app **never moves $BEEP on-chain**. Load = "unlock play credit" gated by on-chain holdings;
Remove/Withdraw = lower play credit. Real tokens always stay in the user's own wallet; winnings are
internal credit only, not redeemable on-chain. **Why:** owner wants a safe beta with no real-money
custody risk; confusion arose because earlier copy ("loaded from wallet", "withdraw back to wallet",
"synced") implied real transfers. **How to apply:** keep all user-facing copy non-custodial — say
"unlock/remove play credit", "tokens stay in your wallet", never "send/withdraw to wallet" or
"synced into balance". If a real-custody model is ever requested, it needs a platform hot wallet +
tx signing + payout broadcasting (large, separate effort).
