describe TicketSquad, sport: 'Nfl' do

  let(:ticket) { Fabricate :ticket }

  it 'returns the score' do
    squad = ticket.ticket_squads.find_by(position: 'quarterbacks')
    qb = Fabricate :player, position: 'QB'
    Fabricate :stat, game: ticket.game, team: squad.team, player: qb, stat: Nfl::Stats::PASSING_YDS, amount: 100
    Fabricate :stat, game: ticket.game, team: squad.team, player: qb, stat: Nfl::Stats::PASSING_TDS, amount: 2
    squad.reload.score.should == 16
  end

end
