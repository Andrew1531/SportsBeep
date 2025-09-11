describe 'api/scoresheets/show.json.v2.jbuilder', sport: 'Mlb' do
  include_context 'authenticated', :user

  let(:ticket) { Fabricate :ticket }
  let(:player) { Fabricate :player }
  let!(:stat) { Fabricate :stat, player: player, game: ticket.game, stat: Mlb::Stats::SINGLES, amount: 2 }

  before do
    assign(:stats, Stat.all)
  end

  it 'returns the players stats' do
    render
    json[:score].should == '2.0'
    json[:stats].should == [
      {
        'name' => 'Singles',
        'abbr' => 'S',
        'amount' => '2',
        'points_per' => '1',
        'points' => '2'
      }
    ]
  end

  it 'busts the cache if the stats change' do
    proc do
      stat.update! amount: 3
      assign(:stats, Stat.all)
    end.should bust_view_cache
  end

end
