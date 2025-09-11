class Mlb::Question < Question
  belongs_to :topic, class_name: 'Mlb::StatTopic'

end