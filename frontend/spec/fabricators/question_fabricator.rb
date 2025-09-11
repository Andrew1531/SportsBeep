Fabricator(:question) do
  transient :topic
  transient :comparison

  type { %w(BestQuestion BustQuestion).sample }
  text 'Test'

  after_build do |question, transients|
    comparison = transients[:comparison] || :more
    topic = transients[:topic] || Mlb::EXPANDED_STATS_FOR.('SP').reject do |s|
      s.in? [Mlb::Stats::HOME_RUNS, Mlb::Stats::DOUBLES, Mlb::Stats::STOLEN_BASES, Mlb::Stats::HITS, Mlb::Stats::STRIKE_OUTS, Mlb::Stats::ERRORS]
    end.sample
    question.topic = StatTopic.find_or_create_by stat: topic.id, comparison: comparison
  end

end