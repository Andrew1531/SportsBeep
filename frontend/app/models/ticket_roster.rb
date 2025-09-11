class TicketRoster
  include ActiveModel::Model

  attr_reader :ticket, :players, :squads
  validate :players_must_be_chosen_for_their_lineup_position_when_available_of_their_official_position

  def initialize(ticket, params = {})
    @ticket = ticket
    @players, @squads = [], []
    Array(params[:players]).each { |p| add_player p }
    Array(params[:squads]).each { |s| add_squad s }
  end

  def save
    @ticket.ticket_players.each do |tp|
      position = @players.find { |p| p[:id].to_i == tp.player.id }.try :[], :position
      tp.update(position: position) if position
    end
    @ticket.ticket_squads.each do |sq|
      if @ticket.persisted?
        # update the team IDs
        team_id = @squads.find { |p| p[:position] == sq.position }.try :[], :id
        sq.update(team_id: team_id) if team_id
      else
        # squad assoc was built in add_squad, so just save it
        sq.save
      end
    end
  end

  def add_player(hash)
    @players << hash
    @ticket.player_ids = player_ids if @ticket.new_record?
  end

  def add_squad(hash)
    @squads << hash
    @ticket.ticket_squads.build team_id: hash[:id], position: hash[:position] if @ticket.new_record?
  end

  def to_h
    { players: @players, squads: @squads }
  end

  def player_ids
    @players.map { |p| p[:id] }
  end

  def squad_ids
    @squads.map { |s| s[:id] }
  end

  private

    def players_must_be_chosen_for_their_lineup_position_when_available_of_their_official_position
      @players.each do |p|
        player = Player.find p[:id]
        bucket = _sport::POSITIONS_FOR_BUCKET.fetch(p[:position], [])
        unless bucket.include?('*') || bucket.include?(player.position_in(@ticket.game))
          errors.add :base, "#{player} cannot be chosen for that position"
        end
      end
    end

end