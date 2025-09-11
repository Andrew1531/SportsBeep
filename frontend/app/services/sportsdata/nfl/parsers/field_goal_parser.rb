module SportsData
  module Nfl
    module Parsers
      class FieldGoalParser < Parser

        def parse
          stats.store ::Nfl::Stats::FG_ATTEMPTS, json['att']
          stats.store ::Nfl::Stats::FG_MADE, json['made']
          stats.store ::Nfl::Stats::FG_PCT, json['pct']
          stats.store ::Nfl::Stats::FG_0_39_YDS, json['made_19'] + json['made_29'] + json['made_39']
          stats.store ::Nfl::Stats::FG_40_49_YDS, json['made_49']
          stats.store ::Nfl::Stats::FG_50_YDS, json['made_50']
          stats.store ::Nfl::Stats::MISSED_FG_0_39_YDS, (json['att_19'] + json['att_29'] + json['att_39']) - (json['made_19'] + json['made_29'] + json['made_39'])
          stats.store ::Nfl::Stats::MISSED_FG_40_49_YDS, json['att_49'] - json['made_49']
          stats.store ::Nfl::Stats::MISSED_FG_50_YDS, json['att_50'] - json['made_50']
        end

        def key
          'field_goal'
        end

      end
    end
  end
end