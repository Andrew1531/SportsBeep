# SportsBeep — Technology Stack & Cardano Ecosystem

*Technical overview for the SportsBeep whitepaper — July 2026*

---

## 1. Platform Overview

SportsBeep is a sports gaming platform combining a DraftKings-style sportsbook and Best/Bust daily fantasy contests, powered by the **$BEEP** token — a native asset on the **Cardano blockchain**. Players connect their own Cardano wallets, sync their on-chain $BEEP into a platform game balance, and wager on real sporting events.

---

## 2. Core Technology Stack

### Web Application
| Layer | Technology |
|---|---|
| Framework | Ruby on Rails 6.1 |
| Language | Ruby 3.2 |
| Web Server | Puma (multi-threaded) |
| Frontend | Server-rendered ERB views, custom CSS (Sass pipeline), vanilla JavaScript |
| Authentication | Devise (secure password hashing, session management, email-based password recovery) |
| Forms | Simple Form |
| JavaScript Runtime | Node.js 20 |

### Data & Infrastructure
| Layer | Technology |
|---|---|
| Production Database | PostgreSQL (managed, persistent) |
| Development Database | SQLite3 |
| Hosting | Replit Autoscale (scales automatically with traffic) |
| Asset Delivery | Rails asset pipeline (Sprockets + SassC), precompiled at build time |
| Transport Security | HTTPS everywhere; all outbound API calls use TLS with full certificate verification |

### Third-Party Services
| Service | Purpose |
|---|---|
| Blockfrost | Cardano blockchain API — wallet balances, token queries, address validation |
| Resend | Transactional email (password resets, account notifications) |
| OpticOdds | Live sportsbook odds feed |
| TheSportsDB | MLB / NFL team and schedule data |
| Web3Forms | Support request routing |
| ESPN CDN | Official team logos (MLB / NFL / NBA / NHL) |

---

## 3. Cardano Ecosystem Integration

### $BEEP Token
- **Type:** Cardano native asset (no smart contract required — native tokens are first-class citizens on Cardano)
- **Identification:** Matched on-chain by policy ID for exact, forgery-proof verification
- **Utility:** Contest entry fees, sportsbook wagers, prize pools

### Wallet Connectivity (CIP-30 Standard)
SportsBeep connects to user wallets through **CIP-30**, Cardano's standard dApp–wallet bridge, meaning any compliant wallet works:
- **Nami** — lightweight browser extension wallet
- **Eternl** — full-featured wallet (formerly ccvault)
- **Flint** — simple multi-platform wallet
- Any other CIP-30 compatible Cardano wallet

Users may also link by **stake address** (`stake1...`), which aggregates every payment address in a wallet — ensuring token balances are never missed across multi-address wallets.

### Blockchain Data Layer — Blockfrost
- Real-time queries of ADA and native token balances
- On-chain $BEEP balance lookups per address or stake account
- Cardano address format validation
- Stake pool data access

### Balance Sync Model
- The platform credits the **difference** between on-chain $BEEP and the current platform balance — preventing double-counting while allowing top-ups
- Only the platform game balance is wagerable; on-chain funds always remain in the user's own custody until synced
- Every balance mutation is bounds-checked and lock-protected server-side

### Why Cardano
- **Native tokens** — $BEEP exists at the protocol level, with no smart-contract attack surface for the token itself
- **Low, predictable fees** — practical for gaming-scale microtransactions
- **Proof-of-Stake (Ouroboros)** — energy-efficient consensus
- **Formal methods heritage** — peer-reviewed research foundation
- **Self-custody first** — users hold their own keys; SportsBeep never takes custody of on-chain assets

---

## 4. Security Practices
- TLS certificate verification enforced on every outbound HTTPS connection
- Devise-managed password hashing (bcrypt) and session handling
- Server-side balance validation on all wagers (client-side checks are convenience only)
- API credentials stored as managed environment secrets — never in source code
- Anti-abuse measures on public forms (honeypots, rate throttling)

---

## 5. Platform Features Snapshot
- **Sportsbook:** spread / total / moneyline markets, team logos, live bet slip, balance guard
- **Daily Fantasy:** Best/Bust format — pick 3 over-performers and 3 under-performers per game slate
- **Wallet:** Cardano wallet connect, $BEEP sync, in-play balance tracking
- **Admin Portal:** user, game, contest, and promo-code management with analytics

---

*© SportsBeep — playsportsbeep on Twitter/X · /sportsbeep on Facebook & Instagram*
