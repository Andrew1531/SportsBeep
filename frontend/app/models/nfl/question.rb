class Nfl::Question < Question
  belongs_to :topic, class_name: 'Nfl::StatTopic'

end