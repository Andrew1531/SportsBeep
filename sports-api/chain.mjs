/**
 * Cardano chain helpers using Lucid + Blockfrost.
 *
 * Exports:
 *   writeMarketSnapshot(markets)          — tx with metadata label 1000
 *   buildBetTx({ marketId, selection, stakeAmount, tokenPolicyId, tokenName, changeAddress })
 *                                         — unsigned CBOR for CIP-30 signing
 */

import { Lucid, Blockfrost, fromText } from 'lucid-cardano';

// ── helpers ──────────────────────────────────────────────────────────────────

function requireEnv(key) {
  const val = process.env[key]?.trim();
  if (!val) throw new Error(`${key} environment variable is required`);
  return val;
}

// Lazily initialise a Lucid instance backed by the treasury wallet.
let _lucidTreasury = null;
async function getTreasuryLucid() {
  if (_lucidTreasury) return _lucidTreasury;
  const projectId = requireEnv('BLOCKFROST_PROJECT_ID');
  const mnemonic  = requireEnv('TREASURY_MNEMONIC');

  const lucid = await Lucid.new(
    new Blockfrost('https://cardano-mainnet.blockfrost.io/api/v0', projectId),
    'Mainnet',
  );
  lucid.selectWalletFromSeed(mnemonic);
  _lucidTreasury = lucid;
  return lucid;
}

// A read-only Lucid instance for building user-side unsigned txs
// (no wallet seed — uses Blockfrost only for UTxO queries).
let _lucidReadOnly = null;
async function getReadOnlyLucid() {
  if (_lucidReadOnly) return _lucidReadOnly;
  const projectId = requireEnv('BLOCKFROST_PROJECT_ID');
  _lucidReadOnly = await Lucid.new(
    new Blockfrost('https://cardano-mainnet.blockfrost.io/api/v0', projectId),
    'Mainnet',
  );
  return _lucidReadOnly;
}

// ── bet address ──────────────────────────────────────────────────────────────
// Bets are sent to the treasury; the oracle/settler resolves winners off-chain.
function getBetAddress() {
  const addr = process.env.TREASURY_ADDRESS?.trim();
  if (!addr) throw new Error('TREASURY_ADDRESS is not set');
  return addr;
}

// ── market snapshot ──────────────────────────────────────────────────────────

/**
 * Writes all active markets as metadata under label 1000 on Cardano.
 * The treasury wallet covers the fee via a min-ADA self-transfer.
 * Returns { txHash }.
 */
export async function writeMarketSnapshot(markets) {
  const lucid = await getTreasuryLucid();
  const treasuryAddr = getBetAddress();

  // Trim the snapshot to fit Cardano's 64-byte-per-value metadata limit.
  // We store { id, home, away, state, score, odds } per event.
  const snapshot = markets.slice(0, 30).map(m => ({
    id:    m.eventId,
    sp:    m.sport,
    h:     (m.homeAbbrev || m.homeTeam).slice(0, 12),
    a:     (m.awayAbbrev || m.awayTeam).slice(0, 12),
    hs:    m.homeScore ?? -1,
    as:    m.awayScore ?? -1,
    st:    m.gameState,
    ck:    m.clock,
    pr:    m.period,
    o:     m.odds?.[0]?.details?.slice(0, 32) ?? '',
    ts:    m.scrapedAt,
  }));

  const tx = await lucid
    .newTx()
    .payToAddress(treasuryAddr, { lovelace: 2_000_000n }) // min-ADA self-send
    .attachMetadata(1000, { v: 1, markets: snapshot })
    .complete();

  const signedTx = await tx.sign().complete();
  const txHash   = await signedTx.submit();
  return { txHash };
}

// ── build unsigned bet tx ────────────────────────────────────────────────────

/**
 * Build an unsigned bet transaction that the user will sign via CIP-30.
 * Returns { unsignedTx } — a CBOR hex string ready for api.signTx().
 *
 * Params:
 *   marketId       — ESPN event ID
 *   selection      — "home" | "away"
 *   stakeAmount    — integer, in the token's smallest unit
 *   tokenPolicyId  — Cardano policy ID hex (56 chars)
 *   tokenName      — token name as UTF-8 string (will be hex-encoded)
 *   changeAddress  — user's bech32 address (from CIP-30 getChangeAddress)
 */
export async function buildBetTx({ marketId, selection, stakeAmount, tokenPolicyId, tokenName, changeAddress }) {
  if (!marketId || !selection || !stakeAmount || !tokenPolicyId || !tokenName || !changeAddress) {
    throw new Error('marketId, selection, stakeAmount, tokenPolicyId, tokenName, and changeAddress are all required');
  }
  if (!['home', 'away'].includes(selection)) {
    throw new Error('selection must be "home" or "away"');
  }
  if (!Number.isInteger(Number(stakeAmount)) || Number(stakeAmount) <= 0) {
    throw new Error('stakeAmount must be a positive integer');
  }
  if (!/^[0-9a-f]{56}$/i.test(tokenPolicyId)) {
    throw new Error('tokenPolicyId must be a 56-character hex string');
  }

  const lucid        = await getReadOnlyLucid();
  lucid.selectWalletFrom({ address: changeAddress });

  const unit         = tokenPolicyId + fromText(tokenName);
  const betAddress   = getBetAddress();
  const betMetadata  = { marketId, selection, stakeAmount: String(stakeAmount), tokenPolicyId, tokenName };

  const tx = await lucid
    .newTx()
    .payToAddress(betAddress, { [unit]: BigInt(stakeAmount) })
    .attachMetadata(1001, betMetadata)  // label 1001 = bet
    .complete({ change: { address: changeAddress } });

  return { unsignedTx: tx.toString() };
}
