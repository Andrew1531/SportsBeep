module SportsData
  module Nfl
    module Parsers
      class ExtraPointParser < Parser

        def parse
          stats.store ::Nfl::Stats::XP_ATTEMPTS, json['att']
          stats.store ::Nfl::Stats::XP_MADE, json['made']
          stats.store ::Nfl::Stats::XP_PCT, json['pct']
        end

        def key
          'extra_point'
        end

      end
    end
  end
end