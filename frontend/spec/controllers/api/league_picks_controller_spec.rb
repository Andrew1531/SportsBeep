describe Api::Mlb::LeaguePicksController, version: 2 do
  include_context 'authenticated', :user

  describe 'GET index' do
    let(:game) { Fabricate :game, start_time: Time.now, league_pick_count: 3 }
    before { BettableGame.new(game).call }

    it 'returns the games in the frame ordered by start time' do
      get :index, game_id: game
      assigns(:game).should == game
      assigns(:league_picks).should =~ game.league_picks.sort_by(&:start_time)
    end
  end
end