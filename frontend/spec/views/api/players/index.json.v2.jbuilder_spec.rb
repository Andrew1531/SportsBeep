describe 'api/players/index.json.v2.jbuilder' do
  include_context 'authenticated', :user

  let(:players) do
    team = Fabricate :team
    Fabricate.times 3, :player, team: team
  end

  before do
    assign(:players, players)
  end

  # Better testing of this partial is done in the show spec
  it 'renders the player attributes' do
    render
    json[:players].each do |_json|
      _json.should include :id, :name, :number, :position, :team, :stats
      _json[:team].should include :id
    end
  end

  describe 'squads JSON', sport: 'Nfl' do
    before { assign(:squads, squads) }

    let(:squads) do
      Fabricate(:ticket).ticket_squads
    end

    it 'renders each squad on each ticket' do
      render
      json[:squads].size.should == 3
      [0, 1, 2].each do |n|
        json[:squads][n].except('team').should == { 'id' => squads[n].team.id, 'game_position' => squads[n].position, 'score' => '0' }
      end
    end
  end

end