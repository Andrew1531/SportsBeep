module SportsData
  module Nfl
    module Parsers
      class DefenseParser < Parser

        def parse
          return if json['position'] == 'TE'
          stats.store ::Nfl::Stats::SACKS, json['sack']
          stats.store ::Nfl::Stats::DEFENSE_INT, json['int']
          stats.store ::Nfl::Stats::FUMBLES_RECOVERED, json['fum_rec']
          stats.store ::Nfl::Stats::SAFETIES, json['sfty']
          stats.store ::Nfl::Stats::BLOCKS, json['bk']
        end

        def key
          'defense'
        end

      end
    end
  end
end