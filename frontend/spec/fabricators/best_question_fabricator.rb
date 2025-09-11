Fabricator(:best_question) do
  transient :topic
  transient :comparison
  transient :sport

  type 'BestQuestion'
  text 'Test'

  after_build do |question, transients|
    comparison = transients[:comparison] || :more
    mod = transients[:sport].try(:safe_constantize) || Mlb
    question.topic = mod::StatTopic.find_or_create_by stat: transients[:topic].id, comparison: comparison
  end

end