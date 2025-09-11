module SportsData
  module Nfl
    class Parser

      attr_accessor :json, :stats

      def initialize(json, stats)
        @json = Hash.new(0).merge(json)
        @stats = stats
      end

      def parse
        parsers.each do |klass|
          instance = klass.new({}, stats)
          instance.json = json.fetch(instance.key, Hash.new(0))
          instance.parse
        end
      end

      private

        def parsers
          @_parsers ||= [
            SportsData::Nfl::Parsers::DefenseParser,
            SportsData::Nfl::Parsers::FieldGoalParser,
            SportsData::Nfl::Parsers::FumbleParser,
            SportsData::Nfl::Parsers::KickReturnParser,
            SportsData::Nfl::Parsers::KickoffParser,
            SportsData::Nfl::Parsers::PassingParser,
            SportsData::Nfl::Parsers::PuntReturnParser,
            SportsData::Nfl::Parsers::ReceivingParser,
            SportsData::Nfl::Parsers::RushingParser,
            SportsData::Nfl::Parsers::TouchdownParser,
            SportsData::Nfl::Parsers::TwoPtConversionParser,
            SportsData::Nfl::Parsers::ExtraPointParser,
          ]
        end


    end
  end
end