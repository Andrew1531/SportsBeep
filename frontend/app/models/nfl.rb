module Nfl
  def self.table_name_prefix; 'nfl_'; end

  AVERAGED_STATS = [
    Nfl::Stats::TWO_PT_CV,
    Nfl::Stats::KICKING_AVG,
    Nfl::Stats::FG_PCT,
    Nfl::Stats::XP_PCT
  ]

  SCORED_STATS = [
    Nfl::Stats::PASSING_TDS,
    Nfl::Stats::PASSING_YDS,
    Nfl::Stats::RUSHING_YDS,
    Nfl::Stats::RUSHING_TDS,
    Nfl::Stats::RECEPTIONS,
    Nfl::Stats::RECEIVING_YDS,
    Nfl::Stats::RECEIVING_TDS,
    Nfl::Stats::PUNT_RETURN_TDS,
    Nfl::Stats::KICK_RETURN_TDS,
    Nfl::Stats::FUMBLES,
    Nfl::Stats::FUMBLES_LOST,
    Nfl::Stats::SACKS,
    Nfl::Stats::PASSING_INT,
    Nfl::Stats::DEFENSE_INT,
    Nfl::Stats::FUMBLES_RECOVERED,
    Nfl::Stats::SAFETIES,
    Nfl::Stats::BLOCKS,
    Nfl::Stats::XP_MADE,
    Nfl::Stats::FG_0_39_YDS,
    Nfl::Stats::FG_40_49_YDS,
    Nfl::Stats::FG_50_YDS,
    Nfl::Stats::MISSED_FG_0_39_YDS,
    Nfl::Stats::MISSED_FG_40_49_YDS,
    Nfl::Stats::MISSED_FG_50_YDS,
    Nfl::Stats::PUNT_RETURN_YDS,
    Nfl::Stats::KICK_RETURN_YDS,
    Nfl::Stats::FG_MADE
  ]

  EXPANDED_STATS_FOR = -> (player) do
    if player.defense?
      [
        Nfl::Stats::SACKS,
        Nfl::Stats::DEFENSE_INT,
        Nfl::Stats::FUMBLES_RECOVERED,
        Nfl::Stats::SAFETIES,
        Nfl::Stats::BLOCKS
      ]
    elsif player.kicker?
      [
        Nfl::Stats::FG_0_39_YDS,
        Nfl::Stats::FG_40_49_YDS,
        Nfl::Stats::FG_50_YDS,
        Nfl::Stats::FG_ATTEMPTS,
        Nfl::Stats::FG_MADE,
        Nfl::Stats::FG_PCT,
        Nfl::Stats::XP_ATTEMPTS,
        Nfl::Stats::XP_MADE,
        Nfl::Stats::XP_PCT,
      ]
    elsif player.quarterback?
      [
        Nfl::Stats::PASSING_TDS,
        Nfl::Stats::PASSING_YDS,
        Nfl::Stats::RUSHING_YDS,
        Nfl::Stats::RUSHING_TDS,
        Nfl::Stats::PASSING_INT,
        Nfl::Stats::FUMBLES
      ]
    elsif player.running_back?
      [
        Nfl::Stats::RUSHING_ATTEMPTS,
        Nfl::Stats::RUSHING_YDS,
        Nfl::Stats::RUSHING_TDS,
        Nfl::Stats::RECEIVING_YDS,
        Nfl::Stats::RECEIVING_TDS,
        Nfl::Stats::FUMBLES,
      ]
    elsif player.receiver?
      [
        Nfl::Stats::RECEPTIONS,
        Nfl::Stats::RECEIVING_YDS,
        Nfl::Stats::RECEIVING_TDS,
        Nfl::Stats::FUMBLES
      ]
    else
      []
    end
  end

  STATS_TO_DISPLAY_UNDER_NAME = -> (player) do
    statdata = case player.position
    when 'TE', 'WR'
      [
        Nfl::Stats::RECEPTIONS,
        Nfl::Stats::RECEIVING_YDS,
        Nfl::Stats::RECEIVING_TDS,
      ]
    when 'FB', 'HB', 'RB', 'TB', 'WB'
      [
        Nfl::Stats::RUSHING_ATTEMPTS,
        Nfl::Stats::RUSHING_YDS,
        Nfl::Stats::RUSHING_TDS,
      ]
    when 'K', 'PK' then
      [
        Nfl::Stats::FG_MADE,
        Nfl::Stats::FG_PCT,
        Nfl::Stats::XP_MADE,
      ]
    else
      []
    end
    statdata.map { |n| player.recent_stats.fetch(n) }
  end

  POSITIONS_FOR_BUCKET = {
    'running_back' => %w(FB HB RB TB WB),
    'tight_end' => %w(TE),
    'wide_receiver' => %w(WR),
    'kicker' => %w(K PK),
    'flex_player' => %w(*)
  }

end
