#!/usr/bin/env node
// Refresh the locally served ESPN team catalog; run with node scripts/sync-sports-catalog.mjs.
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../frontend/public/sports-catalog");
const base = "https://site.api.espn.com/apis/site/v2/sports";
const ncaaLogoMetadataUrl = "https://commons.wikimedia.org/w/api.php?action=query&titles=File:NCAA_logo.svg&prop=imageinfo&iiprop=url%7Cextmetadata&iiurlwidth=500&format=json";
const specs = [
  { key: "ncaaf", name: "NCAA Football", endpoint: "football/college-football" },
  { key: "ncaab", name: "NCAA Men’s Basketball", endpoint: "basketball/mens-college-basketball" },
  // ESPN no longer recognizes soccer/usa.mls (404); its current MLS slug is usa.1.
  { key: "mls", name: "MLS", endpoint: "soccer/usa.1" },
  { key: "epl", name: "English Premier League", endpoint: "soccer/eng.1" },
];
const limit = 1000;
const pngSignature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

async function json(url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`${url}: HTTP ${response.status}`);
  return response.json();
}

async function getTeams(endpoint) {
  const sourceUrls = [];
  const all = [];
  // ESPN honors page, but not offset. Stop only after a short (or empty) page.
  for (let page = 1; ; page++) {
    const url = `${base}/${endpoint}/teams?limit=${limit}&page=${page}`;
    const data = await json(url);
    sourceUrls.push(url);
    const teams = data.sports?.[0]?.leagues?.[0]?.teams;
    if (!Array.isArray(teams)) throw new Error(`No ESPN teams array at ${url}`);
    all.push(...teams.map(({ team }) => team));
    if (teams.length < limit) break;
    if (page > 100) throw new Error(`Unexpected number of ESPN pages: ${endpoint}`);
  }
  if (!all.length) throw new Error(`No ESPN teams returned for ${endpoint}`);
  const ids = new Set(all.map((team) => team.id));
  if (ids.size !== all.length) throw new Error(`Duplicate ESPN IDs in ${endpoint}; pagination may have changed`);
  return { teams: all, sourceUrls };
}

function defaultPng(logos) {
  return logos?.find((logo) => logo.rel?.includes("default") && new URL(logo.href).pathname.endsWith(".png"))?.href;
}

async function localPng(url, relative) {
  const destination = path.join(root, relative);
  try {
    const cached = await readFile(destination);
    if (cached.subarray(0, 8).equals(pngSignature)) return `/sports-catalog/${relative}`;
    throw new Error(`Invalid cached PNG: ${destination}`);
  } catch (error) {
    if (error.code !== "ENOENT") throw error;
  }
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Logo download failed (${response.status}): ${url}`);
  const bytes = Buffer.from(await response.arrayBuffer());
  if (!bytes.subarray(0, 8).equals(pngSignature)) throw new Error(`Not a PNG: ${url}`);
  await mkdir(path.dirname(destination), { recursive: true });
  await writeFile(`${destination}.tmp`, bytes);
  await rename(`${destination}.tmp`, destination);
  return `/sports-catalog/${relative}`;
}

async function inBatches(items, concurrency, task) {
  const results = Array(items.length);
  let cursor = 0;
  const failures = [];
  await Promise.all(Array.from({ length: Math.min(concurrency, items.length) }, async () => {
    while (cursor < items.length) {
      const index = cursor++;
      try {
        results[index] = await task(items[index]);
      } catch (error) {
        failures.push(`${items[index].key}/${items[index].id}: ${error.message}`);
      }
    }
  }));
  if (failures.length) throw new Error(`${failures.length} logo downloads failed:\n${failures.join("\n")}`);
  return results;
}

async function main() {
  await mkdir(root, { recursive: true });
  const sources = {};
  const leagues = [];
  const downloads = [];
  // ESPN's college scoreboards use generic sport icons. Wikimedia Commons
  // identifies this NCAA logo as the official mark, credited to the NCAA.
  const ncaaImage = Object.values((await json(ncaaLogoMetadataUrl)).query?.pages ?? {})[0]?.imageinfo?.[0];
  if (ncaaImage?.extmetadata?.Artist?.value !== "NCAA" ||
      !ncaaImage.extmetadata.ImageDescription?.value.includes("official logo") ||
      !ncaaImage.thumburl?.includes("NCAA_logo.svg") ||
      !ncaaImage.thumburl.includes(".png")) {
    throw new Error(`Cannot verify the NCAA organization logo at ${ncaaLogoMetadataUrl}`);
  }
  const ncaaLogo = "/sports-catalog/ncaa/league.png";
  sources.ncaaLogo = {
    metadata: ncaaLogoMetadataUrl,
    description: ncaaImage.descriptionurl,
    original: ncaaImage.url,
    image: ncaaImage.thumburl,
    attribution: "NCAA (Wikimedia Commons: File:NCAA logo.svg, official organization mark)",
    note: "Shared NCAA organization logo, not a football- or basketball-specific competition logo.",
  };
  downloads.push({ key: "ncaa", id: "league", url: ncaaImage.thumburl, relative: "ncaa/league.png" });
  const teamLists = new Map();
  for (const spec of specs) teamLists.set(spec.key, await getTeams(spec.endpoint));
  // A matching ESPN school ID is evidence of the same school across NCAA sports.
  const basketballTeams = new Map(teamLists.get("ncaab").teams.map((team) => [team.id, team]));
  for (const spec of specs) {
    const { teams, sourceUrls } = teamLists.get(spec.key);
    const scoreboardUrl = `${base}/${spec.endpoint}/scoreboard?limit=1`;
    const scoreboard = await json(scoreboardUrl);
    const league = scoreboard.leagues?.[0];
    if (!league || !Array.isArray(league.logos)) throw new Error(`Missing league metadata at ${scoreboardUrl}`);
    const isNcaa = ["ncaaf", "ncaab"].includes(spec.key);
    sources[spec.key] = {
      teams: sourceUrls,
      leagueLogo: isNcaa ? ncaaLogoMetadataUrl : scoreboardUrl,
      espnLeagueMetadata: scoreboardUrl,
      teamCount: teams.length,
    };
    // ESPN publishes generic sport icons for the NCAA entries, NOT an NCAA league mark.
    const leagueLogoUrl = isNcaa ? null : defaultPng(league.logos);
    if (["mls", "epl"].includes(spec.key) && !leagueLogoUrl) throw new Error(`Missing league logo: ${spec.key}`);
    const entry = { key: spec.key, name: spec.name, logo: isNcaa ? ncaaLogo : `/sports-catalog/${spec.key}/league.png`, teams: [] };
    if (leagueLogoUrl) downloads.push({ key: spec.key, id: "league", url: leagueLogoUrl, relative: `${spec.key}/league.png` });
    const missingLogos = [];
    let sameSchoolLogoCount = 0;
    for (const team of teams) {
      if (!team?.id || !team?.displayName || !team?.abbreviation) throw new Error(`Incomplete ESPN team in ${spec.key}: ${JSON.stringify(team)}`);
      const directLogo = defaultPng(team.logos);
      const sameSchoolLogo = spec.key === "ncaaf" && !directLogo ? defaultPng(basketballTeams.get(team.id)?.logos) : null;
      const url = directLogo ?? sameSchoolLogo;
      if (!url) {
        const reason = "No default PNG logo in ESPN's team list or same-school NCAA men's basketball team list";
        entry.teams.push({ id: team.id, name: team.displayName, abbreviation: team.abbreviation, logo: null, missingLogo: reason });
        missingLogos.push({ id: team.id, name: team.displayName, reason });
        continue;
      }
      const relative = `${spec.key}/teams/${encodeURIComponent(team.id)}.png`;
      const record = { id: team.id, name: team.displayName, abbreviation: team.abbreviation, logo: `/sports-catalog/${relative}` };
      if (sameSchoolLogo) {
        sameSchoolLogoCount++;
        record.logoSource = { league: "ncaab", teamId: team.id, url: sameSchoolLogo };
      }
      entry.teams.push(record);
      downloads.push({ key: spec.key, id: team.id, url, relative });
    }
    sources[spec.key].missingLogoCount = missingLogos.length;
    sources[spec.key].missingLogos = missingLogos;
    if (spec.key === "ncaaf") {
      sources[spec.key].sameSchoolLogoCount = sameSchoolLogoCount;
      sources[spec.key].sameSchoolLogoSource = teamLists.get("ncaab").sourceUrls;
    }
    leagues.push(entry);
    console.log(`${spec.key}: ${entry.teams.length} sourced teams, ${missingLogos.length} missing logos, ${sameSchoolLogoCount} same-school basketball logos`);
  }
  // UFC is a promotion within MMA, not a synonym for all MMA or a team roster.
  const ufcUrl = `${base}/mma/ufc/scoreboard?limit=1`;
  const ufc = (await json(ufcUrl)).leagues?.[0];
  const ufcLogoUrl = defaultPng(ufc?.logos);
  if (ufc?.name !== "Ultimate Fighting Championship" || !ufcLogoUrl) throw new Error(`Missing UFC promotion/logo at ${ufcUrl}`);
  downloads.push({ key: "mma", id: "ufc", url: ufcLogoUrl, relative: "mma/ufc.png" });
  sources.mma = { promotionLogo: ufcUrl, note: "MMA is a sport category; UFC is one promotion, not all MMA." };
  leagues.push({
    key: "mma", name: "MMA", logo: null, teams: [],
    promotion: { id: ufc.id, name: ufc.name, abbreviation: ufc.abbreviation, logo: "/sports-catalog/mma/ufc.png" },
  });
  await inBatches(downloads, 12, ({ url, relative }) => localPng(url, relative));
  const catalog = { generatedAt: new Date().toISOString(), source: "ESPN site API", sources, leagues };
  const output = path.join(root, "catalog.json");
  await writeFile(`${output}.tmp`, `${JSON.stringify(catalog, null, 2)}\n`);
  await rename(`${output}.tmp`, output);
  console.log(`Saved ${output} with ${downloads.length} local PNG logos`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});