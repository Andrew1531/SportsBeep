shared_examples_for 'teams#index' do
  include_context 'authenticated', :user

  describe 'GET index' do
    let!(:teams) { Fabricate.times 3, :team }

    it 'returns all teams' do
      get :index
      response.status.should == 200
      json[:teams].size.should == 3
      json[:teams].each do |team|
        team.should include :id, :name, :market, :abbr, :average_hr_per_game, :primary_color, :secondary_color
      end
    end
  end
end

shared_examples_for 'teams#index-v2' do
  include_context 'authenticated', :user

  describe 'GET index', version: 2 do
    let!(:teams) { Fabricate.times 3, :team }

    it 'returns all teams' do
      get :index
      response.status.should == 200
      json[:teams].size.should == 3
      json[:teams].each do |team|
        team.should include :id, :name, :market, :abbr, :league_pick_stat, :primary_color, :secondary_color
      end
    end
  end

end