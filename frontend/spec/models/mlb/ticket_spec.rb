describe Mlb::Ticket, sport: 'Mlb' do
  let(:ticket) { Fabricate.build :ticket }

  it 'defaults to cached scores to 0' do
    ticket.save
    ticket.cached_score.should == 0.0
    ticket.cached_best_or_bust_score.should == 0.0
  end

  describe '#score' do
    it 'sums up the score of all players' do
      ticket.players.each do |player|
        Fabricate :stat, player: player, game: ticket.game, stat: Mlb::Stats::DOUBLES, amount: 2
      end
      ticket.save
      ticket.score!.should == 24.0
    end

    it 'adds the league pick home runs to the score' do
      # league_pick = Fabricate :game
      # ticket.game.league_picks << league_pick
      # ticket.league_pick_game = league_pick
      # ticket.league_pick_team = league_pick.home_team
      # Fabricate :stat, player: league_pick.home_team.players.first, game: league_pick, team: league_pick.home_team, stat: Mlb::Stats::HOME_RUNS, amount: 5
      # ticket.save
      # ticket.score.should == 15.0
      pending 'league picks were temporarily removed'
    end

    it 'returns 0 for the league pick score if the game is postponed' do
      league_pick = Fabricate :game, status: :postponed
      ticket.game.league_picks << league_pick
      ticket.league_pick_game = league_pick
      ticket.league_pick_team = league_pick.home_team
      Fabricate :stat, player: league_pick.home_team.players.first, game: league_pick, team: league_pick.home_team, stat: Mlb::Stats::HOME_RUNS, amount: 5
      ticket.save
      ticket.score.should == 0
    end
  end
end

describe Ticket, sport: 'Mlb' do
  let(:ticket) { Fabricate.build :ticket }

  specify 'the fabricator is valid' do
    ticket.should be_valid
  end

  describe '.requires_status_updates_for' do
    let(:ticket) { Fabricate :ticket }
    let(:player) { Fabricate :player }

    it 'does not return tickets where the player is not on the roster' do
      ticket.players.should_not include player
      _sport(Contest).upcoming.should include ticket.contest
      _sport(Ticket).requires_status_updates_for(player).should be_empty
    end

    it 'does not return tickets that are part of non-upcoming games' do
      ticket.game.update start_time: 24.hours.ago
      ticket.players -= [ticket.players.last]
      ticket.players << player
      ticket.players.should include player
      _sport(Contest).upcoming.should_not include ticket.contest
      _sport(Ticket).requires_status_updates_for(player).should be_empty
    end

    it 'returns tickets that have the player and are upcoming' do
      ticket.players -= [ticket.players.last]
      ticket.players << player
      ticket.players.should include player
      _sport(Contest).upcoming.should include ticket.contest
      _sport(Ticket).requires_status_updates_for(player).should include ticket
    end
  end

  describe 'validations' do
    it 'needs to have 6 players in it' do
      ticket.players -= [ticket.players.last]
      ticket.should be_invalid
      ticket.errors[:players].should include 'must include exactly 6 players'
    end

    it 'does not accept the same player twice' do
      ticket.players -= [ticket.players.last]
      dupe = ticket.players.sample
      ticket.players << dupe
      ticket.should be_invalid
      ticket.errors[:players].should include 'must contain a particular player only once'
    end

    it 'must only include players from the game that the ticket is for' do
      ticket.players -= [ticket.players.last]
      ticket.players << Fabricate(:player)
      ticket.should be_invalid
      ticket.errors[:players] == 'must all be on a team from the chosen game'
    end

    it 'must only allow 4 players from a single team' do
      players = Fabricate.times 6, :player, team: ticket.game.home_team
      ticket.players = players
      ticket.should be_invalid
      ticket.errors[:base].should include 'No more than 5 players on your roster can come from a single team'
    end

    it 'must have a league pick game that is within the contest game frame' do
      pending 'league picks were temporarily removed'
      # non_league_pick = Fabricate :game, start_time: 20.years.from_now
      # ticket.game.league_picks << Fabricate(:game)
      # ticket.league_pick_game = non_league_pick
      # ticket.league_pick_team = non_league_pick.home_team
      # ticket.should be_invalid
      # ticket.errors[:league_pick_game].should include "Must be in the contest's available league pick games"
    end

    it 'must choose a team that is in the league pick game' do
      pending 'league picks were temporarily removed'
      # league_pick = Fabricate :game
      # random_team = Fabricate :team
      # ticket.game.league_picks << league_pick
      # ticket.league_pick_game = league_pick
      # ticket.league_pick_team = random_team
      # ticket.should be_invalid
      # ticket.errors[:league_pick_team].should include "Must be playing in the league pick game"
    end

    it 'must include a league pick team if there is a league pick game' do
      pending 'league picks were temporarily removed'
      # league_pick = Fabricate(:game)
      # ticket.game.league_picks << league_pick
      # ticket.league_pick_game = league_pick
      # ticket.league_pick_team = nil
      # ticket.should be_invalid
      # ticket.errors[:league_pick_team].should include "can't be blank"
    end

    it 'cannot be created if the game is already live' do
      ticket.game.update start_time: 1.second.ago
      ticket.should be_invalid
      ticket.errors[:base].should include "You cannot join a game that is already in progress"
    end
  end

  describe 'entering a contest' do
    it 'assigns the ticket to an open contest matching the game and pool' do
      contest = Fabricate :contest
      ticket = Fabricate :ticket, pool: contest.pool, game: contest.game
      ticket.contest.should == contest
    end

    it 'creates a new contest from a template when there is not already an ongoing contest' do
      pool = Fabricate :pool
      game = Fabricate :game, pools: [pool], bettable: true
      _sport(Contest).count.should == 0
      Fabricate(:ticket, pool: pool, game: game).tap do |ticket|
        ticket.contest.pool.should == pool
        ticket.game.should == game
        ticket.contest.should == _sport(Contest).last
      end
    end

    it 'creates a new contest from a template when all existing contests are full (maxed on tickets)' do
      contest = Fabricate :contest
      Fabricate.times contest.pool.max_tickets_per_contest, :ticket, pool: contest.pool, game: contest.game
      contest.reload.should be_valid
      expect {
        ticket = Fabricate :ticket, pool: contest.pool, game: contest.game
        ticket.should be_persisted
        ticket.contest.should == _sport(Contest).last
      }.to change(_sport(Contest), :count).by 1
    end

    it 'doesnt create a new contest and fails validation if the contest pool is maxed out' do
      pool = Fabricate :pool, max_contests: 0
      game = Fabricate :game, pools: [pool], bettable: true
      ticket = Fabricate.build :ticket, pool: pool, game: game
      ticket.should be_invalid
      ticket.errors[:contests].should include 'Pool has reached the maximum number of contests'
    end

    it 'does not enter a ticket for a user in the same contest twice' do
      user = Fabricate :user
      contest = Fabricate :contest
      t1 = Fabricate :ticket, pool: contest.pool, game: contest.game, user: user
      t2 = Fabricate :ticket, pool: contest.pool, game: contest.game, user: user
      t1.contest.should_not == t2.contest
    end

    it 'cannot create a ticket for one game/pool more than 5 times' do
      user = Fabricate :user
      contest = Fabricate :contest
      tickets = Fabricate.times 5, :ticket, pool: contest.pool, game: contest.game, user: user
      tickets.each { |t| t.should be_persisted }
      invalid_ticket = Fabricate.build :ticket, pool: contest.pool, game: contest.game, user: user
      invalid_ticket.should be_invalid
    end
  end
end
