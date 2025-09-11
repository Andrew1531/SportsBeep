shared_examples_for 'players#index' do
  include_context 'authenticated', :user
  let(:game) { Fabricate :game }

  it 'returns a list of players by position' do
    get :index, game_id: game
    json[:players].size.should == 50
  end

  it 'returns each players significant information for the build a team screen' do
    get :index, game_id: game
    json[:players].each do |player|
      player.should include :id, :name, :number, :position, :team, :recent_stats, :season_stats
      player[:team].should include :id
    end
  end

  it 'shows each players seasonal stats' do
    player = game.players.find { |p| !p.pitcher? }
    Fabricate :seasonal_stat, player: player, name: 's',  amount: 1
    Fabricate :seasonal_stat, player: player, name: 'ab', amount: 2
    Fabricate :seasonal_stat, player: player, name: 'sb', amount: 3
    get :index, game_id: game
    player = json[:players].find { |p| p['id'] == player.id }
    player[:season_stats].tap do |season|
      season.should include({ 'name' => 'Singles', 'abbr' => 'S',  'amount' => '1' })
      season.should include({ 'name' => 'At bats', 'abbr' => 'AB', 'amount' => '2' })
      season.should include({ 'name' => 'Stolen bases', 'abbr' => 'SB', 'amount' => '3' })
    end
  end
end

shared_examples_for 'players#index-v2' do
  describe 'GET index', version: 2 do
    context 'by game' do
      let!(:game) { Fabricate :game}

      it 'busts cache when player is updated' do
        -> { game.players.sample.touch }.should bust_cache(:index, game_id: game)
      end

      it 'returns name, number, position, stats, and team ID for each player' do
        get :index, game_id: game
        json[:players].each do |p|
          p.should include :id, :name, :number, :position, :team, :stats
          p[:stats].size.should == 5
          p[:team].should include :id
        end
      end
    end

    context 'by ticket' do
      let!(:ticket) { Fabricate :ticket }

      it 'returns name, number, position, and team ID for each player' do
        get :index, ticket_id: ticket
        json[:players].size.should == 6
        json[:players].each do |p|
          p.should include :id, :name, :number, :position, :team, :game_position, :score
          p[:team].should include :id
        end
      end
    end
  end
end