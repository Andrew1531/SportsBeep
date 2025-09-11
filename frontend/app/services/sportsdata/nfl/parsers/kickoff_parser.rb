module SportsData
  module Nfl
    module Parsers
      class KickoffParser < Parser

        def parse
          stats.store ::Nfl::Stats::KICKS, json['kicks']
          stats.store ::Nfl::Stats::KICKING_YDS, json['yds']
          stats.store ::Nfl::Stats::KICKING_AVG, json['avg']
        end

        def key
          'kickoffs'
        end

      end
    end
  end
end