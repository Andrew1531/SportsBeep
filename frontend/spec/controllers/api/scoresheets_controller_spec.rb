describe Api::Mlb::ScoresheetsController, sport: 'Mlb', version: 2 do
  include_context 'authenticated', :user

  context 'when the players have recorded stats for the game already', sportsdata: true do
    let(:ticket) { Fabricate :ticket }
    let(:player) { Fabricate :player }
    let!(:stat)  { Fabricate :stat, player: player, game: ticket.game, stat: Mlb::Stats::SINGLES, amount: 2 }

    it 'shows each players total score and stat breakdown' do
      get :show, ticket_id: ticket, player_id: player
      assigns(:stats).should =~ [stat]
    end
  end
end