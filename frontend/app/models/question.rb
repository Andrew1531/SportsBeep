class Question < ActiveRecord::Base
  before_save { SportsbookOnly.reject! }
  before_destroy { SportsbookOnly.reject! }
  belongs_to :topic, class_name: 'StatTopic'

  attr_accessor :kind

  has_many :answers, class_name: 'QuestionAnswer', dependent: :destroy

  validates :type,     presence: true
  validates :text,     presence: true
  validates :topic_id, presence: true

  delegate :comparison, to: :topic

  def self.sport(sport)
    joins(:topic).where(stat_topics: { type: "#{sport}::StatTopic" })
  end

  def self.mlb
    joins(:topic).where(stat_topics: { type: 'Mlb::StatTopic' })
  end

  def self.nfl
    joins(:topic).where(stat_topics: { type: 'Nfl::StatTopic' })
  end

  def kind
    @kind || type.try(:slice, /(Best|Bust)/)
  end

  def kind=(kind)
    case @kind = kind
    when /bust/i
      self.type = 'BustQuestion'
    when /best/i
      self.type = 'BestQuestion'
    end
  end

end