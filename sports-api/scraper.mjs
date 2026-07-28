/**
 * ESPN scraper — polls all four scoreboard endpoints on a fixed interval
 * and stores the normalized results in an in-memory cache.
 *
 * Exports:
 *   startScraper()          — begin polling (call once on server start)
 *   getMarkets()            — all cached events (markets view)
 *   getScores()             — simplified score feed
 *   getLastScrapedAt()      — ISO timestamp of most recent poll
 */

import { normalizeEvent } from './normalizer.mjs';

const ENDPOINTS = [
  { sport: 'NFL', url: 'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard' },
  { sport: 'NBA', url: 'https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard' },
  { sport: 'MLB', url: 'https://site.api.espn.com/apis/site/v2/sports/baseball/mlb/scoreboard' },
  { sport: 'NHL', url: 'https://site.api.espn.com/apis/site/v2/sports/hockey/nhl/scoreboard' },
];

const POLL_INTERVAL_MS = 20_000; // 20 seconds (well within the 10–30 s spec)

// In-memory cache: Map<eventId, normalizedEvent>
const cache = new Map();
let lastScrapedAt = null;
let errorCount = 0;

async function fetchSport({ sport, url }) {
  const res = await fetch(url, {
    headers: { 'Accept': 'application/json', 'User-Agent': 'SportsBeep/1.0' },
  });
  if (!res.ok) throw new Error(`ESPN ${sport} responded ${res.status}`);
  const data = await res.json();

  let updated = 0;
  for (const event of data.events ?? []) {
    const normalized = normalizeEvent(sport, event);
    if (normalized) {
      cache.set(normalized.eventId, normalized);
      updated++;
    }
  }
  return updated;
}

async function pollAll() {
  const results = await Promise.allSettled(ENDPOINTS.map(fetchSport));
  const errors = results.filter(r => r.status === 'rejected').map(r => r.reason?.message);
  if (errors.length) {
    errorCount++;
    console.warn(`[scraper] ${errors.length} endpoint(s) failed: ${errors.join('; ')}`);
  } else {
    errorCount = 0;
  }
  lastScrapedAt = new Date().toISOString();
  const total = results.reduce((acc, r) => acc + (r.value ?? 0), 0);
  console.log(`[scraper] ${lastScrapedAt} — ${total} events cached (${cache.size} total)`);
}

export function startScraper() {
  // First poll immediately, then every POLL_INTERVAL_MS
  pollAll().catch(e => console.error('[scraper] initial poll failed:', e.message));
  setInterval(() => {
    pollAll().catch(e => console.error('[scraper] poll failed:', e.message));
  }, POLL_INTERVAL_MS);
  console.log(`[scraper] started — polling every ${POLL_INTERVAL_MS / 1000}s`);
}

export function getMarkets() {
  return Array.from(cache.values());
}

export function getScores() {
  return Array.from(cache.values()).map(e => ({
    sport:     e.sport,
    eventId:   e.eventId,
    homeTeam:  e.homeTeam,
    awayTeam:  e.awayTeam,
    homeScore: e.homeScore,
    awayScore: e.awayScore,
    gameState: e.gameState,
    clock:     e.clock,
    period:    e.period,
    detail:    e.detail,
    scrapedAt: e.scrapedAt,
  }));
}

export function getLastScrapedAt() {
  return lastScrapedAt;
}
