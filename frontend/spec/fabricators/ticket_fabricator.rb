Fabricator(:ticket) do
  user
  game
  type { ENV['SPORT'] && "#{ENV['SPORT']}::Ticket" }

  after_build do |ticket|
    ticket.game = nil if ticket.contest

    BettableGame.new(ticket.game).call!
    ticket.pool ||= ticket.game.pools.sample
    ticket.roster = "#{ENV['SPORT']}::TicketRoster".constantize.new(ticket)

    case ENV['SPORT']
    when 'Mlb'
      bucket = Mlb::POSITIONS_FOR_BUCKET
      positions = %w(SP C 1B 2B LF RP)
      ticket.game.teams.cycle(3) do |team|
        position = positions.pop
        player = Fabricate(:player, position: position, team: team).tap(&:save)
        gamepos = bucket.find { |_, val| val.include? position }.first
        ticket.roster.add_player id: player.id, position: gamepos
      end
    when 'Nfl'
      bucket = Nfl::POSITIONS_FOR_BUCKET
      positions = %w(RB WR K RB TE)
      positions.each do |position|
        player = Fabricate(:player, position: position, team: ticket.game.teams.sample).tap(&:save)
        gamepos = bucket.find { |_, val| val.include? position }.first
        ticket.roster.add_player id: player.id, position: gamepos
      end
      ticket.roster.add_squad id: ticket.game.home_team.id, position: 'quarterbacks'
      ticket.roster.add_squad id: ticket.game.home_team.id, position: 'defense'
      ticket.roster.add_squad id: ticket.game.away_team.id, position: 'special_teams'
    end

    ticket.league_pick_game ||= ticket.game.league_picks.sample
    ticket.league_pick_team ||= ticket.league_pick_game.try(:home_team)
  end
end