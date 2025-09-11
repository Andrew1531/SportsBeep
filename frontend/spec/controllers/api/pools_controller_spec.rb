describe Api::Mlb::PoolsController, version: 2 do
  include_context 'authenticated', :user

  let(:game) { Fabricate :game, pools: pools }
  let(:pools) { Fabricate.times 2, :pool }

  it 'retrieves the game and pools' do
    get :index, game_id: game
    assigns(:game).should == game
    assigns(:pools).should =~ game.pools
  end

end