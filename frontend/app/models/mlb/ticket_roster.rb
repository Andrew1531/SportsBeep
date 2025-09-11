class Mlb::TicketRoster < TicketRoster

  validate :must_include_each_game_position

  def must_include_each_game_position
    return if @players.empty?
    positions = @players.map { |p| p[:position] }
    errors.add(:base, 'Must choose a pitcher') unless positions.include? 'pitcher'
    errors.add(:base, 'Must choose a catcher') unless positions.include? 'catcher'
    errors.add(:base, 'Must choose a corner infielder') unless positions.include? 'corner_infielder'
    errors.add(:base, 'Must choose a middle infielder') unless positions.include? 'middle_infielder'
    errors.add(:base, 'Must choose an outfielder') unless positions.include? 'outfielder'
  end

end