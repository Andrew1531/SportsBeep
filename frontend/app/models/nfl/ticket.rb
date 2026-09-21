class Nfl::Ticket < Ticket

  TICKET_SIZE = 5
  validates :players, length: { is: TICKET_SIZE, message: "must include exactly #{TICKET_SIZE} players" }
  has_many :question_attempts, class_name: 'Nfl::QuestionAttempt', foreign_key: :ticket_id, dependent: :destroy

  def self.requires_status_updates_for(player)
    joins(:players, :contest).where(players: { id: player.id }).merge(Nfl::Contest.upcoming)
  end

end
