class TicketSquad < ActiveRecord::Base
  belongs_to :ticket, touch: true
  belongs_to :team, touch: true

  validates :team, presence: true

  def score
    @_score ||= to_squad.stats.total
  end

  def to_squad
    case position
    when 'quarterbacks'
      Nfl::QuarterbackSquad
    when 'defense'
      Nfl::DefenseSquad
    when 'special_teams'
      Nfl::SpecialTeamsSquad
    end.new(ticket)
  end

end
