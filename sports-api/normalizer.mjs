/**
 * Normalize a raw ESPN competition object into the unified SportsBeep format.
 * Works for NFL, NBA, MLB, NHL — all share the same competition shape.
 */

export function normalizeEvent(sport, event) {
  const comp = event.competitions?.[0];
  if (!comp) return null;

  const status = comp.status ?? {};
  const statusType = status.type ?? {};

  const home = comp.competitors?.find(c => c.homeAway === 'home');
  const away = comp.competitors?.find(c => c.homeAway === 'away');

  const odds = (comp.odds ?? []).map(o => ({
    provider:    o.provider?.name ?? 'Unknown',
    details:     o.details ?? null,
    // Moneylines — ESPN stores them under moneyline.{home|away}.close.odds
    homeOdds:    o.moneyline?.home?.close?.odds ?? null,
    awayOdds:    o.moneyline?.away?.close?.odds ?? null,
    // Spread — points from flat field; juice is standard -110 for MLB
    spread:      o.spread ?? null,
    // Total — points from flat overUnder; juice from nested total object
    overUnder:   o.overUnder ?? null,
    overOdds:    o.total?.over?.close?.odds ?? null,
    underOdds:   o.total?.under?.close?.odds ?? null,
  }));

  return {
    sport,
    eventId:    event.id,
    homeTeam:   home?.team?.displayName ?? home?.team?.name ?? 'Home',
    homeAbbrev: home?.team?.abbreviation ?? '',
    awayTeam:   away?.team?.displayName ?? away?.team?.name ?? 'Away',
    awayAbbrev: away?.team?.abbreviation ?? '',
    homeScore:  home?.score != null ? Number(home.score) : null,
    awayScore:  away?.score != null ? Number(away.score) : null,
    gameState:  statusType.state ?? 'pre',   // pre | in | post
    clock:      status.displayClock ?? '0:00',
    period:     status.period ?? 0,
    description: statusType.description ?? statusType.detail ?? '',
    detail:     statusType.shortDetail ?? '',
    odds,
    scrapedAt:  new Date().toISOString(),
  };
}
