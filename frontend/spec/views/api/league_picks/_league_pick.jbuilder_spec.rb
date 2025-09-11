# league picks were temporarily removed
# describe 'api/resources/_league_pick.jbuilder', sport: 'Mlb' do
#   include_context 'authenticated', :user
#   let(:game) { Fabricate :game, league_pick_count: 3 }
#   let(:ticket) { Fabricate :ticket, game: game }
#   let(:league_pick) { ticket.league_pick }

#   before do
#     view.stub(:league_pick) { league_pick }
#     Fabricate :team_stat, stat: Mlb::Stats::RUNS, amount: 1, team: league_pick.team
#     Fabricate :team_stat, stat: Mlb::Stats::BATTING_AVERAGE, amount: 0.250, team: league_pick.team
#     Fabricate :team_stat, stat: Mlb::Stats::ON_BASE_PCT, amount: 0.333, team: league_pick.team
#     Fabricate :team_stat, stat: Mlb::Stats::SLUGGING_PCT, amount: 0.200, team: league_pick.team
#   end

#   describe 'formatting' do
#     it 'shows 0 instead of 0.0' do
#       render
#       json[:amount].should == '0'
#       json[:score].should == '0'
#     end
#   end

#   context 'when the seasonal stats are stale' do
#     before do
#       player = league_pick.team.players.sample
#       Fabricate :seasonal_stat, stat: Mlb::Stats::HOME_RUNS, amount: 20, player: player
#       Fabricate :stat, stat: Mlb::Stats::HOME_RUNS, amount: 3, game: league_pick.game, team: league_pick.team, player: player
#     end

#     it 'adds the game home runs to the seasonal stat home runs' do
#       # render
#       # json[:amount].should == '3'
#       # json[:score].should == '9'
#       # json[:scorers].first[:season_total].should == '23'
#       pending 'league picks were temporarily removed'
#     end
#   end

#   context 'when the seasonal stats have already been updated' do
#     before do
#       player = league_pick.team.players.sample
#       Fabricate :seasonal_stat, stat: Mlb::Stats::HOME_RUNS, amount: 25, player: player, updated_at: 7.days.from_now
#       Fabricate :stat, stat: Mlb::Stats::HOME_RUNS, amount: 3, game: league_pick.game, team: league_pick.team, player: player
#     end

#     it 'just uses the seasonal stats value' do
#       # render
#       # json[:scorers].first[:season_total].should == '25'
#       pending 'league picks were temporarily removed'
#     end
#   end

# end