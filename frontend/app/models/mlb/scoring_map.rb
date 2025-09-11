module Mlb
  class ScoringMap

    MAPPING = {
      Mlb::Stats::WALKS => 1,
      Mlb::Stats::DOUBLES => 2,
      Mlb::Stats::HIT_BY_PITCH => 1,
      Mlb::Stats::HOME_RUNS => 4,
      Mlb::Stats::OUTS => -0.25,
      Mlb::Stats::RUNS => 1,
      Mlb::Stats::RBIS => 1,
      Mlb::Stats::SINGLES => 1,
      Mlb::Stats::STOLEN_BASES => 2,
      Mlb::Stats::TRIPLES => 3
    }

    PITCHER_OVERRIDE_MAPPING = {
      Mlb::Stats::WALKS => -0.25,
      Mlb::Stats::ERA => -1,
      Mlb::Stats::HITS_ALLOWED => -0.25,
      Mlb::Stats::INNINGS_PITCHED => 1,
      Mlb::Stats::STRIKE_OUTS => 1,
      Mlb::Stats::WINS => 4
    }

    def fetch(statdata, player)
      to_h(player).fetch(statdata, 0)
    end

    def to_h(player)
      mapping = MAPPING.dup
      mapping.merge! PITCHER_OVERRIDE_MAPPING if player.pitcher?
      mapping
    end

  end
end
