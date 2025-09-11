describe 'api/teams/rankings.json.v2.jbuilder' do
  include_context 'authenticated', :user
  let(:team) { Fabricate :team }

  before do
    Fabricate :team_stat, stat: Mlb::Stats::RUNS, amount: 1, team: team
    Fabricate :team_stat, stat: Mlb::Stats::BATTING_AVERAGE, amount: 0.250, team: team
    Fabricate :team_stat, stat: Mlb::Stats::ON_BASE_PCT, amount: 0.333, team: team
    Fabricate :team_stat, stat: Mlb::Stats::SLUGGING_PCT, amount: 0.200, team: team
    assign(:rankings, team.rankings)
  end

  it 'includes rankings for runs, avg, obp, and slg' do
    render
    json[:rankings].should include({ 'name' => 'Runs', 'rank' => 1, 'value' => '1' })
    json[:rankings].should include({ 'name' => 'Batting average', 'rank' => 1, 'value' => '.250' })
    json[:rankings].should include({ 'name' => 'On base', 'rank' => 1, 'value' => '.333' })
    json[:rankings].should include({ 'name' => 'Slugging pct', 'rank' => 1, 'value' => '.200' })
  end
end

describe 'api/teams/rankings.json.v2.jbuilder', sport: 'Nfl' do
  include_context 'authenticated', :user
  let(:team) { Fabricate :team }

  before do
    Fabricate :team_stat, stat: Nfl::Stats::OFFENSIVE_YPG, amount: 1, team: team
    Fabricate :team_stat, stat: Nfl::Stats::PASSING_YPG, amount: 2, team: team
    Fabricate :team_stat, stat: Nfl::Stats::RUSHING_YPG, amount: 3, team: team
    Fabricate :team_stat, stat: Nfl::Stats::INTERCEPTIONS_PG, amount: 4, team: team
    assign(:rankings, team.rankings)
  end

  it 'includes rankings for runs, avg, obp, and slg' do
    render
    json[:rankings].should =~ [
      { 'name' => 'Offensive YPG', 'rank' => 1, 'value' => '1' },
      { 'name' => 'Passing YPG', 'rank' => 1, 'value' => '2' },
      { 'name' => 'Rushing YPG', 'rank' => 1, 'value' => '3' },
      { 'name' => 'Ints / Game', 'rank' => 1, 'value' => '4' }
    ]
  end
end