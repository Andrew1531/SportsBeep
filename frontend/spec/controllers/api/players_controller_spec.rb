describe Api::Mlb::PlayersController, version: 2 do
  include_context 'authenticated', :user

  describe 'GET index' do
    context 'by game' do
      let(:game) { Fabricate :game }
      it 'retrieves the players on both teams' do
        get :index, game_id: game
        assigns(:players).should =~ game.players
      end

      it 'excludes players who arent on the current roster' do
        game.players.last.update(on_current_roster: false)
        get :index, game_id: game
        assigns(:players).should =~ game.players.reverse.drop(1).reverse
      end

      it 'has an empty @squads' do
        get :index, game_id: game
        assigns(:squads).should be_nil
      end
    end

    context 'by ticket' do
      let(:ticket) { Fabricate :ticket, user: user }

      it 'retrieves the players on the ticket roster' do
        get :index, ticket_id: ticket
        assigns(:players).should =~ ticket.players
      end

      it 'does not exclude players who arent on the current roster' do
        ticket.players.last.update(on_current_roster: false)
        get :index, ticket_id: ticket
        assigns(:players).should =~ ticket.players
      end
    end
  end

  describe 'GET show' do
    let(:player) { Fabricate :player }
    it 'retrieves the player by ID' do
      get :show, id: player
      assigns(:player).should == player
    end
  end

  describe 'GET previous' do
    let(:team) { Fabricate :team }
    let(:player) { team.players.sample }
    let!(:game1) { Fabricate :game, start_time: 1.day.ago, home_team: team }
    let!(:game2) { Fabricate :game, start_time: 1.minute.ago, home_team: team }

    before do
      Fabricate.times 3, :stat, game: game1, player: player
    end

    it 'returns only the players who played in the last game' do
      get :previous, game_id: game2
      assigns(:players).should =~ [player]
    end
  end

end

describe Api::Nfl::PlayersController, version: 2, sport: 'Nfl' do
  include_context 'authenticated', :user

  context 'by ticket' do
    let(:ticket) { Fabricate :ticket, user: user }

    it 'retrieves the players on the ticket roster' do
      get :index, ticket_id: ticket
      assigns(:squads).should =~ ticket.ticket_squads
    end
  end
end