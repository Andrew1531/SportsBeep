module Nfl
  class ScoringMap

    MAPPING = {
      Nfl::Stats::PASSING_TDS => 6,
      Nfl::Stats::PASSING_YDS => 0.04,
      Nfl::Stats::PASSING_INT => 0,
      Nfl::Stats::RUSHING_YDS => 0.1,
      Nfl::Stats::RUSHING_TDS => 6,
      Nfl::Stats::RECEPTIONS => 1,
      Nfl::Stats::RECEIVING_YDS => 0.1,
      Nfl::Stats::RECEIVING_TDS => 6,
      Nfl::Stats::PUNT_RETURN_TDS => 6,
      Nfl::Stats::KICK_RETURN_TDS => 6,
      Nfl::Stats::FUMBLES_LOST => -2,
      Nfl::Stats::TWO_PT_CV => 2,
      Nfl::Stats::PUNT_RETURN_YDS => 0.04,
      Nfl::Stats::KICK_RETURN_YDS => 0.04,
    }

    DEFENSE_OVERRIDE_MAPPING = {
      Nfl::Stats::SACKS => 1,
      Nfl::Stats::DEFENSE_INT => 2,
      Nfl::Stats::FUMBLES_RECOVERED => 1,
      Nfl::Stats::SAFETIES => 1,
      Nfl::Stats::BLOCKS => 2
    }

    KICKING_OVERRIDE_MAPPING = {
      Nfl::Stats::XP_MADE => 1,
      Nfl::Stats::FG_0_39_YDS => 3,
      Nfl::Stats::FG_40_49_YDS => 4,
      Nfl::Stats::FG_50_YDS => 5,
      Nfl::Stats::MISSED_FG_0_39_YDS => -3,
      Nfl::Stats::MISSED_FG_40_49_YDS => -2,
      Nfl::Stats::MISSED_FG_50_YDS => -1
    }

    def fetch(statdata, player)
      to_h(player).fetch(statdata, 0)
    end

    def to_h(player)
      mapping = MAPPING.dup
      mapping.merge! DEFENSE_OVERRIDE_MAPPING if player.defense?
      mapping.merge! KICKING_OVERRIDE_MAPPING if player.kicker?
      mapping
    end

  end
end