Fabricate :administrator, email: 'getinked53@gmail.com', password: '$sb2025$' unless Administrator.exists?(email: 'getinked53@gmail.com')
Setting.create if Setting.count.zero?

# seed some default pools (should be configurable in admin portal)
# [0, 20, 50, 100, 250, 500, 1000, 2500, 5000]
[0].each do |prize_pool|
  params = { max_tickets_per_contest: 10, entry_fee_multiplier: 1.1, default: true, prize_pool: prize_pool }
  Pool.find_by(prize_pool: prize_pool) || Pool.create!(params)
end

Mlb::StatTopic.seed Mlb::Stats::AT_BATS, :more
Mlb::StatTopic.seed Mlb::Stats::BATTING_AVERAGE, :more
Mlb::StatTopic.seed Mlb::Stats::SINGLES, :more
Mlb::StatTopic.seed Mlb::Stats::DOUBLES, :more
Mlb::StatTopic.seed Mlb::Stats::TRIPLES, :more
Mlb::StatTopic.seed Mlb::Stats::HOME_RUNS, :more
Mlb::StatTopic.seed Mlb::Stats::STRIKE_OUTS, :less
Mlb::StatTopic.seed Mlb::Stats::HITS, :less
Mlb::StatTopic.seed Mlb::Stats::ON_BASE_PCT, :more
Mlb::StatTopic.seed Mlb::Stats::SLUGGING_PCT, :more
Mlb::StatTopic.seed Mlb::Stats::RUNS, :more
Mlb::StatTopic.seed Mlb::Stats::RBIS, :more
Mlb::StatTopic.seed Mlb::Stats::WALKS, :more
Mlb::StatTopic.seed Mlb::Stats::HIT_BY_PITCH, :more
Mlb::StatTopic.seed Mlb::Stats::STOLEN_BASES, :more
Mlb::StatTopic.seed Mlb::Stats::OUTS, :less
Mlb::StatTopic.seed Mlb::Stats::ERA, :more
Mlb::StatTopic.seed Mlb::Stats::INNINGS_PITCHED, :more
Mlb::StatTopic.seed Mlb::Stats::RUNS_ALLOWED, :less
Mlb::StatTopic.seed Mlb::Stats::HITS_ALLOWED, :more
Mlb::StatTopic.seed Mlb::Stats::HOME_RUNS_ALLOWED, :more
Mlb::StatTopic.seed Mlb::Stats::HIT_BATTER, :more
Mlb::StatTopic.seed Mlb::Stats::WHIP, :more
Mlb::StatTopic.seed Mlb::Stats::ON_BASE_AVERAGE, :more
Mlb::StatTopic.seed Mlb::Stats::ERRORS, :less

if BestQuestion.mlb.count < 3
  BestQuestion.create! topic: Mlb::StatTopic[Mlb::Stats::HOME_RUNS], text: 'Which team will hit the most home runs?'
  BestQuestion.create! topic: Mlb::StatTopic[Mlb::Stats::DOUBLES], text: 'Which team will give up the least doubles?'
  BestQuestion.create! topic: Mlb::StatTopic[Mlb::Stats::ERRORS], text: 'Which team will not make the most errors?'
end

if BustQuestion.mlb.count < 3
  BustQuestion.create! topic: Mlb::StatTopic[Mlb::Stats::STOLEN_BASES], text: 'Which team will steal the least?'
  BustQuestion.create! topic: Mlb::StatTopic[Mlb::Stats::HITS], text: 'Which will not make the most hits?'
  BustQuestion.create! topic: Mlb::StatTopic[Mlb::Stats::STRIKE_OUTS], text: 'Which team will strike out the most?'
end

Nfl::StatTopic.seed Nfl::Stats::TURNOVERS, :less
Nfl::StatTopic.seed Nfl::Stats::PENALTIES, :less
Nfl::StatTopic.seed Nfl::Stats::PENALTY_YDS, :less
Nfl::StatTopic.seed Nfl::Stats::RED_ZONE_PCT, :more
Nfl::StatTopic.seed Nfl::Stats::THIRD_DOWN_CV, :more
Nfl::StatTopic.seed Nfl::Stats::FOURTH_DOWN_CV, :more
Nfl::StatTopic.seed Nfl::Stats::TOTAL_YDS, :more
Nfl::StatTopic.seed Nfl::Stats::RUSHING_YDS, :more
Nfl::StatTopic.seed Nfl::Stats::PASSING_YDS, :more
Nfl::StatTopic.seed Nfl::Stats::FIRST_DOWNS, :more
Nfl::StatTopic.seed Nfl::Stats::CHALLENGES, :more

if BestQuestion.nfl.count < 3
  BestQuestion.create! topic: Nfl::StatTopic[Nfl::Stats::TURNOVERS], text: 'Which team will have the least turnovers?'
  BestQuestion.create! topic: Nfl::StatTopic[Nfl::Stats::PENALTIES], text: 'Which team will have the least penalties?'
  BestQuestion.create! topic: Nfl::StatTopic[Nfl::Stats::RED_ZONE_PCT], text: 'Which team will have the highest red zone percentage?'
end

if BustQuestion.nfl.count < 3
  BustQuestion.create! topic: Nfl::StatTopic[Nfl::Stats::THIRD_DOWN_CV], text: 'Which team will have the worst third down conversion rate?'
  BustQuestion.create! topic: Nfl::StatTopic[Nfl::Stats::FOURTH_DOWN_CV], text: 'Which team will have the worst fourth down conversion rate?'
  BustQuestion.create! topic: Nfl::StatTopic[Nfl::Stats::TOTAL_YDS], text: 'Which team will have the least total yards?'
end
