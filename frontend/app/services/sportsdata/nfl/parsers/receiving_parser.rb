module SportsData
  module Nfl
    module Parsers
      class ReceivingParser < Parser

        def parse
          stats.store ::Nfl::Stats::RECEPTIONS, json['rec']
          stats.store ::Nfl::Stats::RECEIVING_YDS, json['yds']
          stats.store ::Nfl::Stats::RECEIVING_TDS, json['td']
        end

        def key
          'receiving'
        end

      end
    end
  end
end