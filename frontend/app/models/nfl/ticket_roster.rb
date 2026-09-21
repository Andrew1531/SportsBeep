class Nfl::TicketRoster < TicketRoster

  validate :must_include_each_player_position
  validate :must_include_each_squad_position
  validate :squads_must_be_playing_in_ticket_game

  def must_include_each_player_position
    return if @players.empty? && @ticket.persisted?
    positions = @players.map { |p| p[:position] }
    errors.add(:base, 'Must choose a tight end') unless positions.include? 'tight_end'
    errors.add(:base, 'Must choose a running back') unless positions.include? 'running_back'
    errors.add(:base, 'Must choose a wide receiver') unless positions.include? 'wide_receiver'
    errors.add(:base, 'Must choose a kicker') unless positions.include? 'kicker'
    errors.add(:base, 'Must choose a flex player') unless positions.include? 'flex_player'
    errors.add(:base, 'Each player slot must be chosen exactly once') unless positions.sort == Nfl::POSITIONS_FOR_BUCKET.keys.sort
  end

  def must_include_each_squad_position
    return if @squads.empty? && @ticket.persisted?
    positions = @squads.map { |sq| sq[:position] }
    errors.add(:base, 'Must choose a QB squad') unless positions.include? 'quarterbacks'
    errors.add(:base, 'Must choose a defensive squad') unless positions.include? 'defense'
    errors.add(:base, 'Must choose a special teams squad') unless positions.include? 'special_teams'
    errors.add(:base, 'Each squad slot must be chosen exactly once') unless positions.sort == %w[quarterbacks defense special_teams].sort
  end

  def squads_must_be_playing_in_ticket_game
    teams = ticket.game.teams.map(&:id)
    @squads.each do |sq|
      if teams.exclude? sq[:id].to_i
        errors.add(:base, "Ticket squad is not playing in this ticket's game")
      end
    end
  end

end