shared_examples_for 'league_picks#index' do
  include_context 'authenticated', :user

  let(:game) { Fabricate :game, start_time: Time.now }
  let!(:league_picks) { Fabricate.times 3, :game, start_time: rand(1..3).hours.from_now }

  before { BettableGame.new(game).call }

  it 'returns the games in the frame ordered by start time' do
    get :index, game_id: game
    league_picks.sort_by(&:start_time).map(&:id).should == json[:games].map { |g| g['id'] }
  end

end