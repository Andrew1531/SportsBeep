module SportsData
  module Nfl
    module Parsers
      class PuntReturnParser < Parser

        def parse
          stats.store ::Nfl::Stats::PUNT_RETURN_TDS, json['td']
          stats.store ::Nfl::Stats::PUNT_RETURN_YDS, json['yds']
        end

        def key
          'punt_return'
        end

      end
    end
  end
end