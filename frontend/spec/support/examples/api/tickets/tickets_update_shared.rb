shared_examples_for 'tickets#update' do
  include_context 'authenticated', :user

  describe 'PUT update' do
    it 'updates the players on a ticket' do
      put :update, id: ticket, ticket: { players: players_param }
      response.status.should == 204
      ticket.reload.ticket_players.map(&:position).each do |pos|
        pos.should == 'BP'
      end
    end

    it 'updates the league picks' do
      league_pick_game = Fabricate :game
      league_pick_team = league_pick_game.home_team
      ticket.contest.game.league_picks << league_pick_game
      put :update, id: ticket, ticket: { league_pick_game_id: league_pick_game.id, league_pick_team_id: league_pick_team.id }
      response.status.should == 204
      ticket.reload.league_pick_game.should == league_pick_game
      ticket.reload.league_pick_team.should == league_pick_team
    end

    it 'does not update the ticket if it is after game time' do
      ticket.game.update start_time: 1.second.ago
      put :update, id: ticket, ticket: { players: players_param }
      response.status.should == 422
      json[:error].should == "You cannot join a game that is already in progress"
    end

  end
end