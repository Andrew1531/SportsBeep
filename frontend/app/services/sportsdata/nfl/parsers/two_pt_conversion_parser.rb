module SportsData
  module Nfl
    module Parsers
      class TwoPtConversionParser < Parser

        def parse
          stats.store ::Nfl::Stats::TWO_PT_CV, json['pass'] + json['rec'] + json['rush']
        end

        def key
          'two_point_conversion'
        end

      end
    end
  end
end