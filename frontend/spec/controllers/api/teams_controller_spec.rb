describe Api::Mlb::TeamsController, version: 2 do
  include_context 'authenticated', :user

  describe 'GET index' do
    let!(:teams) { Fabricate.times 3, :team }

    it 'returns all teams' do
      get :index
      response.status.should == 200
      assigns(:teams).should =~ teams
    end

    it 'does not show non-standard teams' do
      nonstandard = ['Retired', 'National League', 'Unknown Team', 'American League', 'Minor League']
      nonstandard.each { |name| Fabricate :team, name: name }
      get :index
      Mlb::Team.count.should == 8
      assigns(:teams).should =~ teams
    end
  end

  describe 'GET rankings' do
    let(:team) { Fabricate :team }
    it 'retrieves the team rankings' do
      get :rankings, id: team
      assigns(:team).should == team
      assigns(:rankings).should =~ team.rankings
    end
  end
end