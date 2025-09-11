module SportsData
  module Nfl
    module Parsers
      class FumbleParser < Parser

        def parse
          stats.store ::Nfl::Stats::FUMBLES, json['fum']
          stats.store ::Nfl::Stats::FUMBLES_LOST, json['lost']
        end

        def key
          'fumbles'
        end

      end
    end
  end
end