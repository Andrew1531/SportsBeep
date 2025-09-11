module SportsData
  module Nfl
    module Parsers
      class RushingParser < Parser

        def parse
          stats.store ::Nfl::Stats::RUSHING_ATTEMPTS, json['att']
          stats.store ::Nfl::Stats::RUSHING_YDS, json['yds']
          stats.store ::Nfl::Stats::RUSHING_TDS, json['td']
        end

        def key
          'rushing'
        end

      end
    end
  end
end