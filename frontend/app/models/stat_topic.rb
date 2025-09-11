class StatTopic < ActiveRecord::Base
  has_many :questions, foreign_key: :topic_id, dependent: :destroy

  before_validation -> { self.comparison = comparison.to_s }

  validates :stat, presence: true
  validates :comparison, presence: true, inclusion: { in: %w(more less) }

  def stat
    case (statdata = super)
    when StatData
      statdata
    else
      StatData.find(statdata)
    end
  end

  def self.[](statdata)
    find_by(stat: statdata.id)
  end

  def self.seed(statdata, comparison)
    find_or_create_by!(stat: statdata.id, comparison: comparison)
  end

  def to_s
    stat
  end

end
