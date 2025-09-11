shared_examples_for 'tickets#league_pick' do
  include_context 'authenticated', :user
  let(:ticket) { Fabricate :ticket, game: Fabricate(:game, league_pick_count: 3) }

  let(:stat) do
    case ENV['SPORT']
    when 'Mlb' then :hr
    when 'Nfl' then :td
    end
  end

  describe 'GET league_pick' do
    before do
      Fabricate :stat, name: stat, amount: 3, game: ticket.league_pick_game, team: ticket.league_pick_team
    end

    it 'returns details about the league pick score' do
      get :league_pick, id: ticket
      json[:amount].should == 3
      json[:score].should == 9
      json[:scorers].each do |_json|
        _json.should include :name, :season_total
      end
      json[:team].should include :id
    end

    context 'when the seasonal stats are stale' do
      before do
        player = ticket.league_pick_team.players.sample
        Fabricate :seasonal_stat, name: stat, amount: 20, player: player
        Fabricate :stat, name: stat, amount: 3, game: ticket.league_pick_game, team: ticket.league_pick_team, player: player
      end

      it 'adds the game home runs to the seasonal stat home runs' do
        get :league_pick, id: ticket
        json[:scorers].first[:season_total].should == 23
      end
    end

    context 'when the seasonal stats have already been updated' do
      before do
        player = ticket.league_pick_team.players.sample
        Fabricate :seasonal_stat, name: stat, amount: 25, player: player, updated_at: 7.days.from_now
        Fabricate :stat, name: stat, amount: 3, game: ticket.league_pick_game, team: ticket.league_pick_team, player: player
      end

      it 'just uses the seasonal stats value' do
        get :league_pick, id: ticket
        json[:scorers].first[:season_total].should == 25
      end
    end
  end
end