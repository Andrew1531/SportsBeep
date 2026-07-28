/**
 * SportsBeep Sports API — Node.js + Express
 *
 * Endpoints:
 *   GET  /api/markets          → all odds + game data (normalized ESPN feed)
 *   GET  /api/scores           → simplified score feed
 *   POST /api/chain/snapshot   → writes market snapshot to Cardano (metadata label 1000)
 *   POST /api/chain/bet        → builds unsigned Cardano bet transaction
 *
 * Runs on PORT (default 3001) alongside the existing Rails app on 5000.
 */

import express from 'express';
import cors    from 'cors';
import { startScraper, getMarkets, getScores, getLastScrapedAt } from './scraper.mjs';
import { writeMarketSnapshot, buildBetTx } from './chain.mjs';

const app  = express();
const PORT = process.env.SPORTS_API_PORT || 3001;

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Health ────────────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ ok: true, scrapedAt: getLastScrapedAt() });
});

// ── GET /api/markets ──────────────────────────────────────────────────────────
// Returns all cached events with full odds + game data.
app.get('/api/markets', (_req, res) => {
  const markets = getMarkets();
  res.json({
    ok:        true,
    count:     markets.length,
    scrapedAt: getLastScrapedAt(),
    markets,
  });
});

// ── GET /api/scores ───────────────────────────────────────────────────────────
// Returns a lightweight score feed (no odds data).
app.get('/api/scores', (_req, res) => {
  const scores = getScores();
  res.json({
    ok:        true,
    count:     scores.length,
    scrapedAt: getLastScrapedAt(),
    scores,
  });
});

// ── POST /api/chain/snapshot ──────────────────────────────────────────────────
// Writes all active markets as a Cardano metadata transaction (label 1000).
// Uses the treasury wallet — requires TREASURY_MNEMONIC + BLOCKFROST_PROJECT_ID.
app.post('/api/chain/snapshot', async (_req, res) => {
  try {
    const markets = getMarkets();
    if (markets.length === 0) {
      return res.status(400).json({ ok: false, error: 'No market data cached yet — wait for the scraper to run.' });
    }
    const result = await writeMarketSnapshot(markets);
    res.json({ ok: true, ...result, marketCount: markets.length });
  } catch (err) {
    console.error('[/api/chain/snapshot]', err.message);
    res.status(500).json({ ok: false, error: err.message });
  }
});

// ── POST /api/chain/bet ───────────────────────────────────────────────────────
// Builds an unsigned Cardano bet transaction for CIP-30 wallet signing.
// Body: { marketId, selection, stakeAmount, tokenPolicyId, tokenName, changeAddress }
app.post('/api/chain/bet', async (req, res) => {
  try {
    const { marketId, selection, stakeAmount, tokenPolicyId, tokenName, changeAddress } = req.body ?? {};
    const result = await buildBetTx({ marketId, selection, stakeAmount, tokenPolicyId, tokenName, changeAddress });
    res.json({ ok: true, ...result });
  } catch (err) {
    console.error('[/api/chain/bet]', err.message);
    const status = err.message.includes('required') || err.message.includes('must be') ? 400 : 500;
    res.status(status).json({ ok: false, error: err.message });
  }
});

// ── 404 ───────────────────────────────────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ ok: false, error: 'Not found' }));

// ── Start ─────────────────────────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log(`[sports-api] listening on port ${PORT}`);
  startScraper();
});
