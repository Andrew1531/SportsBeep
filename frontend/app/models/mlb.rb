module Mlb
  def self.table_name_prefix; 'mlb_'; end

  AVERAGED_STATS = [
    Mlb::Stats::BATTING_AVERAGE,
    Mlb::Stats::ERA,
    Mlb::Stats::ON_BASE_AVERAGE,
    Mlb::Stats::ON_BASE_PCT,
    Mlb::Stats::SLUGGING_PCT,
    Mlb::Stats::WHIP
  ]

  SCORED_STATS = [
    Mlb::Stats::WALKS,
    Mlb::Stats::DOUBLES,
    Mlb::Stats::ERA,
    Mlb::Stats::HITS_ALLOWED,
    Mlb::Stats::HIT_BY_PITCH,
    Mlb::Stats::HOME_RUNS,
    Mlb::Stats::INNINGS_PITCHED,
    Mlb::Stats::STRIKE_OUTS,
    Mlb::Stats::OUTS,
    Mlb::Stats::RUNS,
    Mlb::Stats::RBIS,
    Mlb::Stats::SINGLES,
    Mlb::Stats::STOLEN_BASES,
    Mlb::Stats::TRIPLES,
    Mlb::Stats::WINS
  ]

  SCORING_MULTIPLIER = -> (stat, position = nil) do
    position ||= stat.player.position
    mapping = { bb: 1, d: 2, hbp: 1, hr: 4, out: -0.25, r: 1, rbi: 1, s: 1, sb: 2, t: 3 }
    mapping.merge! bb: -0.25, era: -1, ha: -0.25, ip: 1, k: 1, win: 4 if position =~ /(SP|CP|RP|pitcher)/i
    stat = stat.name unless String === stat
    mapping.fetch(stat.intern, 0)
  end

  EXPANDED_STATS_FOR = -> (player) do
    position = player.try(:position) || player
    case position
    when 'SP', 'CP' then
      [
        Mlb::Stats::WINS,
        Mlb::Stats::LOSSES,
        Mlb::Stats::ERA,
        Mlb::Stats::STRIKE_OUTS,
        Mlb::Stats::WALKS,
        Mlb::Stats::STARTS,
        Mlb::Stats::INNINGS_PITCHED,
        Mlb::Stats::HITS_ALLOWED,
        Mlb::Stats::RUNS_ALLOWED,
        Mlb::Stats::HOME_RUNS,
        Mlb::Stats::WHIP,
        Mlb::Stats::ON_BASE_AVERAGE
      ]
    when 'RP'
      [
        Mlb::Stats::WINS,
        Mlb::Stats::SAVES,
        Mlb::Stats::ERA,
        Mlb::Stats::STRIKE_OUTS,
        Mlb::Stats::WALKS,
        Mlb::Stats::STARTS,
        Mlb::Stats::INNINGS_PITCHED,
        Mlb::Stats::HITS_ALLOWED,
        Mlb::Stats::RUNS_ALLOWED,
        Mlb::Stats::HOME_RUNS,
        Mlb::Stats::WHIP,
        Mlb::Stats::ON_BASE_AVERAGE
      ]
    else
      [
        Mlb::Stats::AT_BATS,
        Mlb::Stats::BATTING_AVERAGE,
        Mlb::Stats::HOME_RUNS,
        Mlb::Stats::RBIS,
        Mlb::Stats::WALKS,
        Mlb::Stats::SINGLES,
        Mlb::Stats::DOUBLES,
        Mlb::Stats::TRIPLES,
        Mlb::Stats::HIT_BY_PITCH,
        Mlb::Stats::STOLEN_BASES,
        Mlb::Stats::ON_BASE_PCT,
        Mlb::Stats::SLUGGING_PCT,
        Mlb::Stats::STRIKE_OUTS
      ]
    end
  end

  STATS_TO_DISPLAY_UNDER_NAME = -> (player) do
    statdata = case player.position
    when 'SP', 'CP'
      [
        Mlb::Stats::WINS,
        Mlb::Stats::LOSSES,
        Mlb::Stats::ERA,
        Mlb::Stats::STRIKE_OUTS,
        Mlb::Stats::WALKS
      ]
    when 'RP'
      [
        Mlb::Stats::WINS,
        Mlb::Stats::SAVES,
        Mlb::Stats::ERA,
        Mlb::Stats::STRIKE_OUTS,
        Mlb::Stats::WALKS
      ]
    else
      [
        Mlb::Stats::AT_BATS,
        Mlb::Stats::BATTING_AVERAGE,
        Mlb::Stats::HOME_RUNS,
        Mlb::Stats::RBIS,
        Mlb::Stats::WALKS
      ]
    end
    statdata.map { |n| player.recent_stats.fetch(n) }
  end

  POSITIONS_FOR_BUCKET = {
    'pitcher' => %w(SP CP RP),
    'catcher' => %w(C),
    'corner_infielder' => %w(1B 3B),
    'middle_infielder' => %w(2B SS),
    'outfielder' => %w(LF CF RF),
    'flex_player' => %w(*)
  }

end