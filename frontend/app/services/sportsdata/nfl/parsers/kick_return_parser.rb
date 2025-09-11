module SportsData
  module Nfl
    module Parsers
      class KickReturnParser < Parser

        def parse
          stats.store ::Nfl::Stats::KICK_RETURN_TDS, json['td']
          stats.store ::Nfl::Stats::KICK_RETURN_YDS, json['yds']
        end

        def key
          'kick_return'
        end

      end
    end
  end
end