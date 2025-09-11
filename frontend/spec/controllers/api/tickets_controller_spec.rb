describe Api::Mlb::TicketsController, version: 2 do
  include_context 'authenticated', :user

  let(:ticket) { Fabricate :ticket }

  describe 'POST create' do
    it 'creates the ticket' do
      post :create, ticket: ticket.roster.to_h, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 201
      assigns(:ticket).should be_persisted
      assigns(:ticket).reload.players.each do |player|
        tp = TicketPlayer.find_by(ticket: assigns(:ticket), player: player)
        pos = player.position
        gamepos = Mlb::POSITIONS_FOR_BUCKET.detect { |_, v| v.include? pos }.first
        tp.position.should == gamepos
      end
    end

    it 'fails when omitting a position' do
      params = ticket.roster.to_h[:players].map do |player|
        if player[:position] == 'pitcher'
          Player.find(player[:id]).update(position: 'C')
          player.merge(position: 'catcher')
        else
          player
        end
      end
      post :create, ticket: { players: params }, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 422
      json[:error].should =~ %r[Must choose a pitcher]
    end

    it 'fails when picking a player outside of their position' do
      params = ticket.roster.to_h
      params[:players].first[:position] = 'nope'
      post :create, ticket: params, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 422
      json[:error].should =~ %r[cannot be chosen for that position]
    end

    it 'creates a ticket and sets a league pick' do
      league_pick_game = Fabricate :game
      league_pick_team = league_pick_game.home_team
      ticket.contest.game.league_picks << league_pick_game
      post :create, ticket: ticket.roster.to_h.merge({ league_pick_game_id: league_pick_game.id, league_pick_team_id: league_pick_team.id }), game_id: ticket.game.id, pool_id: ticket.pool.id
      assigns(:ticket).league_pick_game.should == league_pick_game
      assigns(:ticket).league_pick_team.should == league_pick_team
    end

    it 'fails when trying to enter the same game/pool over 5 times' do
      5.times do
        post :create, ticket: ticket.roster.to_h, game_id: ticket.game.id, pool_id: ticket.pool.id
        response.status.should == 201
      end
      post :create, ticket: ticket.roster.to_h, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 422
      assigns(:ticket).should have_error_message /You have joined this game and pool the maximum number of times/
    end

    it 'returns a error when the ticket is invalid' do
      post :create, ticket: { player_ids: [] }, game_id: ticket.game.id, pool_id: ticket.pool.id
      response.status.should == 422
      assigns(:ticket).should have_error_message /exactly 6 players/
    end
  end

  describe 'GET show' do
    it 'retrieves the ticket' do
      get :show, id: ticket
      assigns(:ticket).should == ticket
    end

    # it 'busts the cache if the ticket score changes' do
    #   player = ticket.players.sample.tap { |p| p.update(position: '1B') }
    #   Fabricate :stat, game: ticket.game, player: player, stat: Mlb::Stats::SINGLES
    #   -> {
    #     ticket.stats.all.sample.update(amount: 50)
    #     UpdateCachedTicketScores.new.perform(ticket.game)
    #   }.should bust_cache(:show, id: ticket)
    # end
  end

  describe 'PUT update' do
    it 'updates the players on a ticket' do
      put :update, id: ticket, ticket: ticket.roster.to_h
      response.status.should == 204
      assigns(:ticket).reload.players.each do |player|
        tp = TicketPlayer.find_by(ticket: assigns(:ticket), player: player)
        pos = player.position
        gamepos = Mlb::POSITIONS_FOR_BUCKET.detect { |_, v| v.include? pos }.first
        tp.position.should == gamepos
      end
    end

    it 'does not update ticket players when only sending 5 players' do
      post :create, ticket: ticket.roster.to_h, game_id: ticket.game.id, pool_id: ticket.pool.id
      put :update, id: assigns(:ticket).reload.id, ticket: { players: ticket.roster.to_h[:players].take(5) }
      response.status.should == 422
      assigns(:ticket).reload.players.length.should == 6
    end

    it 'updates the league picks' do
      league_pick_game = Fabricate :game
      league_pick_team = league_pick_game.home_team
      ticket.contest.game.league_picks << league_pick_game
      put :update, id: ticket, ticket: { league_pick_game_id: league_pick_game.id, league_pick_team_id: league_pick_team.id }
      response.status.should == 204
      assigns(:ticket).reload.league_pick_game.should == league_pick_game
      assigns(:ticket).reload.league_pick_team.should == league_pick_team
    end

    it 'does not update the ticket if it is after game time' do
      ticket.game.update start_time: 1.second.ago
      put :update, id: ticket, ticket: ticket.roster.to_h
      response.status.should == 422
      assigns(:ticket).should have_error_message "You cannot join a game that is already in progress"
    end

    it 'fails to update when a player is not in their actual position' do
      params = ticket.roster.players.map { |hash| hash.merge(position: 'nope') }
      put :update, id: ticket, ticket: { players: params }
      response.status.should == 422
      json[:error].should =~ %r[cannot be chosen for that position]
    end
  end

  describe 'GET index' do
    let(:contest) { Fabricate :contest }

    it 'returns a list of all the tickets in the contest' do
      Fabricate :ticket # random ticket that should not be in @tickets
      tickets = Fabricate.times 6, :ticket, contest: contest
      get :index, contest_id: contest
      assigns(:tickets).should =~ tickets
    end

    describe 'user avatars' do
      before do
        Fabricate.times 6, :ticket, contest: contest
        AvatarUploader.enable_processing = true
        contest.users.each do |user|
          user.avatar = Rack::Test::UploadedFile.new(File.open(Rails.root.join('spec', 'support', 'test-avatar.png')))
          user.save!
        end
      end

      it 'returns xxhdpi by default' do
        get :index, contest_id: contest
        json[:tickets].each do |ticket|
          user = User.find_by username: ticket[:user][:username]
          ticket[:user][:avatar_url].should == user.avatar.url(:xxhdpi)
        end
      end

      %w(mdpi hdpi xhdpi xxhdpi).each do |size|
        it "returns with the #{size} avatar" do
          get :index, contest_id: contest, avatar_size: size
          json[:tickets].each do |ticket|
            user = User.find_by username: ticket[:user][:username]
            ticket[:user][:avatar_url].should == user.avatar.url(size)
          end
        end
      end

      after do
        AvatarUploader.enable_processing = false
      end
    end

    it 'uses the cached ticket scores' do
      tickets = Fabricate.times 6, :ticket, contest: contest
      tickets.each do |t|
        Fabricate :stat, player: t.players[0], game: contest.game, stat: Mlb::Stats::SINGLES, amount: 2
      end
      UpdateCachedTicketScores.new.perform(contest.game)
      get :index, contest_id: contest
      json['tickets'].each do |t|
        t['score'].should == '2.0'
      end
    end
  end

  describe 'GET league_pick' do
    it 'retrieves the ticket league pick' do
      get :league_pick, id: ticket
      assigns(:league_pick).should == ticket.league_pick
    end
  end
end

describe Api::Nfl::TicketsController, version: 2, sport: 'Nfl' do
  include_context 'authenticated', :user
  let(:ticket) { Fabricate :ticket }

  it 'creates a ticket with squad positions' do
    post :create, ticket: ticket.roster.to_h, game_id: ticket.game.id, pool_id: ticket.pool.id
    assigns(:ticket).ticket_squads.map(&:position).should =~ %w(quarterbacks special_teams defense)
  end

  it 'fails when omitting a squad position' do
    params = ticket.roster.to_h
    params[:squads] = params[:squads].take(2)
    post :create, ticket: params, game_id: ticket.game.id, pool_id: ticket.pool.id
    response.status.should == 422
    json[:error].should =~ %r[Must choose a special teams squad]
  end

  it 'fails when choosing a squad not on the ticket', document: false do
    put :update, id: ticket, ticket: ticket.roster.to_h.merge(squads: [{ id: 3, position: 'quarterbacks' }, { id: 1, position: 'defense' }, { id: 1, position: 'special_teams' }])
    response.status.should == 422
    json[:error].should =~ %r[Ticket squad is not playing in this ticket's game]
  end

  it 'updates the players on a ticket' do
    ticket.ticket_squads.find_by(position: 'quarterbacks').team.id.should == 1
    put :update, id: ticket, ticket: ticket.roster.to_h.merge(squads: [{ id: 2, position: 'quarterbacks' }, { id: 1, position: 'defense' }, { id: 1, position: 'special_teams' }])
    response.status.should == 204
    ticket.reload.ticket_squads.find_by(position: 'quarterbacks').team.id.should == 2
  end

end