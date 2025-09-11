class Mlb::Ticket < Ticket

  TICKET_SIZE = 6
  validates :players, length: { is: TICKET_SIZE, message: "must include exactly #{TICKET_SIZE} players" }

  def self.requires_status_updates_for(player)
    joins(:players, :contest).where(players: { id: player.id }).merge(Mlb::Contest.upcoming)
  end

end
