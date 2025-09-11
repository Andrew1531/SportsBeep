shared_examples_for 'tickets#create' do
  let(:ticket) { Fabricate :ticket }
  let(:players_param) do
    ticket.players.map do |p|
      { id: p.id, position: 'BP' }
    end
  end

  describe 'POST create' do
    context 'when authenticated' do
      include_context 'authenticated', :user

      it 'creates the ticket' do
        post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
        response.status.should == 201
        json.should include :id, :contest
        json[:contest].should include :id
        Ticket.find(json[:id]).ticket_players.map(&:position).each { |pos| pos.should == 'BP' }
        json[:players].map { |p| p['game_position'].should == 'BP' }
      end

      it 'does not update ticket players when the ticket is invalid' do
        post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
        response.status.should == 201
        id = json[:id]
        put :update, id: json[:id], ticket: { players: players_param.take(5) }
        response.status.should == 422
        Ticket.find(id).players.length.should == 6
      end

      it 'creates a ticket and sets a league pick' do
        league_pick_game = Fabricate :game
        league_pick_team = league_pick_game.home_team
        ticket.contest.game.league_picks << league_pick_game
        post :create, ticket: { players: players_param, league_pick_game_id: league_pick_game.id, league_pick_team_id: league_pick_team.id }, game_id: ticket.game.id, pool_id: ticket.pool.id
        response.status.should == 201
        json.should include :id, :contest, :league_pick
        json[:contest].should include :id
        json[:players].each do |p|
          p.should include :position, :game_position
        end
        json[:league_pick].should include :game, :team
        json[:league_pick][:game][:id].should == league_pick_game.id
        json[:league_pick][:team][:id].should == league_pick_team.id
      end

      it 'fails when trying to enter the same game/pool over 5 times' do
        5.times do
          post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
          response.status.should == 201
        end

        post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
        response.status.should == 422
        json[:error].should include 'You have joined this game and pool the maximum number of times'
      end

      it 'returns a 404 when the game cant be found' do
        post :create, ticket: { players: players_param }, pool_id: ticket.pool.id
        response.status.should == 404
        json[:error].should include 'Game'
      end

      it 'returns a 404 when the pool cant be found' do
        post :create, ticket: { players: players_param }, pool_id: ticket.pool.id
        response.status.should == 404
        json[:error].should include 'Game'
      end

      it 'returns a error when the ticket is invalid' do
        post :create, ticket: { player_ids: [] }, game_id: ticket.game.id, pool_id: ticket.pool.id
        response.status.should == 422
        json[:error].should match /exactly 6 players/
      end

    end

    context 'when not authenticated' do
      it 'does not create a ticket and returns a 401' do
        request.env['HTTP_AUTHORIZATION'] = "Token token=NOPE"
        post :create
        response.status.should == 401
      end
    end
  end
end

shared_examples_for 'tickets#create-v2' do
  let(:ticket) { Fabricate :ticket }
  let(:players_param) do
    ticket.players.map do |p|
      { id: p.id, position: 'BP' }
    end
  end

  describe 'POST create', version: 2 do
    include_context 'authenticated', :user

    it 'creates the ticket' do
      post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 201
      json.should include :id, :contest
      json[:contest].should include :id
      Ticket.find(json[:id]).ticket_players.map(&:position).each { |pos| pos.should == 'BP' }
    end

    it 'does not update ticket players when the ticket is invalid' do
      post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 201
      id = json[:id]
      put :update, id: json[:id], ticket: { players: players_param.take(5) }
      response.status.should == 422
      Ticket.find(id).players.length.should == 6
    end

    it 'creates a ticket and sets a league pick' do
      league_pick_game = Fabricate :game
      league_pick_team = league_pick_game.home_team
      ticket.contest.game.league_picks << league_pick_game
      post :create, ticket: { players: players_param, league_pick_game_id: league_pick_game.id, league_pick_team_id: league_pick_team.id }, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 201
      json.should include :id, :contest, :league_pick
      json[:contest].should include :id
      json[:league_pick].should include :game, :team
      json[:league_pick][:game][:id].should == league_pick_game.id
      json[:league_pick][:team][:id].should == league_pick_team.id
    end

    it 'fails when trying to enter the same game/pool over 5 times' do
      5.times do
        post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
        response.status.should == 201
      end

      post :create, ticket: { players: players_param }, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 422
      json[:error].should include 'You have joined this game and pool the maximum number of times'
    end

    it 'returns a 404 when the game cant be found' do
      post :create, ticket: { players: players_param }, pool_id: ticket.pool.id
      response.status.should == 404
      json[:error].should include 'Game'
    end

    it 'returns a 404 when the pool cant be found' do
      post :create, ticket: { players: players_param }, pool_id: ticket.pool.id
      response.status.should == 404
      json[:error].should include 'Game'
    end

    it 'returns a error when the ticket is invalid' do
      post :create, ticket: { player_ids: [] }, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 422
      json[:error].should match /exactly 6 players/
    end

  end
end