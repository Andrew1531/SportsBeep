describe Api::Nfl::SquadsController, sport: 'Nfl', version: 2 do
  include_context 'authenticated', :user
  let(:ticket) { Fabricate :ticket }
  let(:team) { ticket.game.home_team }

  before do
    ticket.ticket_squads.each { |sq| sq.update!(team: team) }
    ticket.reload
  end

  describe 'stat population' do
    it 'populates the quarterback stats' do
      qb = Fabricate :player, team: team, position: 'QB'
      Fabricate :stat, game: ticket.game, team: team, player: qb, stat: Nfl::Stats::PASSING_YDS.id, amount: 2
      Fabricate :stat, game: ticket.game, team: team, player: qb, stat: Nfl::Stats::PASSING_YDS.id, amount: 3
      Fabricate :stat, game: ticket.game, team: team, player: qb, stat: Nfl::Stats::PASSING_TDS.id, amount: 1
      Fabricate :stat, game: ticket.game, team: team, player: qb, stat: Nfl::Stats::RUSHING_YDS.id, amount: 5
      get :show, id: 'quarterbacks', ticket_id: ticket
      json[:score].should == '6.7'
      json[:stats].should =~ [
        { 'name' => 'Passing yards', 'abbr' => 'PASS YD', 'points_per' => 0.04, 'amount' => '5', 'points' => '.2' },
        { 'name' => 'Passing TDs', 'abbr' => 'PASS TD', 'points_per' => 6, 'amount' => '1', 'points' => '6' },
        { 'name' => 'Rushing yards', 'abbr' => 'RUSH YD', 'points_per' => 0.1, 'amount' => '5', 'points' => '.5' }
      ]
    end

    it 'doesnt count the rushing yds of other players in the QB squad score' do
      qb = Fabricate :player, team: team, position: 'QB'
      Fabricate :stat, game: ticket.game, team: team, player: qb, stat: Nfl::Stats::RUSHING_YDS.id, amount: 5
      Fabricate :stat, game: ticket.game, team: team, player: ticket.players.sample, stat: Nfl::Stats::RUSHING_YDS.id, amount: 5
      ticket.ticket_squads.find_by(position: 'quarterbacks').score.should == 0.5
      get :show, id: 'quarterbacks', ticket_id: ticket
      json[:stats].should =~ [
        { 'name' => 'Rushing yards', 'abbr' => 'RUSH YD', 'points_per' => 0.1, 'amount' => '5', 'points' => '.5' }
      ]
    end

    it 'populates the defense stats' do
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'CB'), stat: Nfl::Stats::SACKS.id, amount: 1
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'CB'), stat: Nfl::Stats::DEFENSE_INT.id, amount: 2
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'CB'), stat: Nfl::Stats::FUMBLES_RECOVERED.id, amount: 3
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'CB'), stat: Nfl::Stats::SAFETIES.id, amount: 4
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'CB'), stat: Nfl::Stats::BLOCKS.id, amount: 5
      get :show, id: 'defense', ticket_id: ticket
      json[:stats].should =~ [
        { 'name' => 'Sacks', 'abbr' => 'SCK', 'points_per' => 1.0, 'amount' => '1', 'points' => '1' },
        { 'name' => 'Interceptions', 'abbr' => 'INT', 'points_per' => 2.0, 'amount' => '2', 'points' => '4' },
        { 'name' => 'Fumbles recovered', 'abbr' => 'FR', 'points_per' => 1.0, 'amount' => '3', 'points' => '3' },
        { 'name' => 'Safety', 'abbr' => 'SFTY', 'points_per' => 1.0, 'amount' => '4', 'points' => '4' },
        { 'name' => 'Blocks', 'abbr' => 'BLK', 'points_per' => 2.0, 'amount' => '5', 'points' => '10' }
      ]
    end

    it 'populates the special teams stats' do
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'KR'), stat: Nfl::Stats::PUNT_RETURN_YDS.id, amount: 1
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'KR'), stat: Nfl::Stats::KICK_RETURN_YDS.id, amount: 2
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'KR'), stat: Nfl::Stats::FUMBLES_LOST.id, amount: 3
      Fabricate :stat, game: ticket.game, team: team, player: Fabricate(:player, team: team, position: 'KR'), stat: Nfl::Stats::BLOCKS.id, amount: 4
      get :show, id: 'special_teams', ticket_id: ticket
      json[:stats].should =~ [
        { 'name' => 'Punt return yards', 'abbr' => 'PR YD', 'points_per' => 0.04, 'amount' => '1', 'points' => '.04' },
        { 'name' => 'Kick return yards', 'abbr' => 'KR YD', 'points_per' => 0.04,'amount' => '2', 'points' => '.08' },
      ]
    end
  end

end
