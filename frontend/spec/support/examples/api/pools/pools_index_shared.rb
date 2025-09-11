shared_examples_for 'pools#index' do
  include_context 'authenticated', :user

  let(:game) { Fabricate :game, pools: pools }
  let(:pools) do
    [Fabricate(:pool, prize_pool: 20), Fabricate(:pool, prize_pool: 5000)]
  end

  it 'returns a list of pools assigned to a game' do
    get :index, game_id: game
    json[:pools].size.should == 2
    json[:pools].each do |hash|
      hash.should include :id, :prize_pool, :entry_fee
    end
  end
end