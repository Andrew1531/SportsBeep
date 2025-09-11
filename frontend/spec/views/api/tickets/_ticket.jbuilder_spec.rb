describe 'api/resources/_ticket.jbuilder' do
  include_context 'authenticated', :user

  let(:ticket) { Fabricate :ticket, game: game }
  let(:game) { Fabricate :game, league_pick_count: 3 }

  let(:batter) { ticket.players.where.not(position: %w(SP RP CP)).first }
  before do
    view.stub(:ticket) { ticket }
  end

  it 'shows the ticket id, score, username, and contest ID' do
    stat = Fabricate :stat, player: batter, game: ticket.game, stat: Mlb::Stats::SINGLES, amount: 2
    ticket.reload
    render
    json[:id].should == 1
    json[:score].should == '2.0'
    json[:prize_pool].should == ticket.pool.prize_pool
    json[:user][:username].should == ticket.user.username
    json[:contest][:id].should == 1
  end

  it 'shows the ticket placing' do
    ticket2 = Fabricate :ticket, contest: ticket.contest
    Fabricate :stat, player: ticket2.players.where.not(position: %w(SP RP CP)).first, game: ticket.game, name: :s, amount: 2
    render
    json[:placing].should == 2
  end

  it 'shows the ticket best or bust score' do
    question = ticket.questions.joins(:topic).find_by(type: 'BestQuestion', stat_topics: { stat: Mlb::Stats::HOME_RUNS.id })
    home, away = ticket.game.teams
    Fabricate :stat, team: home, game: ticket.game, stat: Mlb::Stats::HOME_RUNS, amount: 5
    Fabricate :stat, team: away, game: ticket.game, stat: Mlb::Stats::HOME_RUNS, amount: 2
    Fabricate :question_answer, question: question, answer: home, ticket: ticket, time: 7.0
    ticket.reload
    render
    json[:best_or_bust_score].should == '1.4'
  end

  it 'shows the league pick score and game/team' do
    # stat = Fabricate :stat, stat: Mlb::Stats::HOME_RUNS, amount: 2, team: ticket.league_pick.team, game: ticket.league_pick.game
    # render
    # json[:league_pick][:game][:id].should == ticket.league_pick_game.id
    # json[:league_pick][:team][:id].should == ticket.league_pick_team.id
    # json[:league_pick][:score].should == '6.0'
    pending 'league picks were temporarily removed'
  end

end