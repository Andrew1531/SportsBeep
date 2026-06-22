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
