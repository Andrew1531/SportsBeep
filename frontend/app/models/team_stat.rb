class TeamStat < ActiveRecord::Base
  belongs_to :team, touch: true

  include StatReference
  include Formattable

  def self.sport(sport)
    joins(:team).where(teams: { type: "#{sport}::Team" })
  end

end
