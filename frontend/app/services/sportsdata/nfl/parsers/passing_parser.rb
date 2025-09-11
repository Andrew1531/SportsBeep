module SportsData
  module Nfl
    module Parsers
      class PassingParser < Parser

        def parse
          stats.store ::Nfl::Stats::PASSING_TDS, json['td']
          stats.store ::Nfl::Stats::PASSING_YDS, json['yds']
          stats.store ::Nfl::Stats::PASSING_INT, json['int']
        end

        def key
          'passing'
        end

      end
    end
  end
end