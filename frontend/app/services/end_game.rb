class EndGame

  attr_accessor :game

  def initialize(game)
    @game = game
    @game.status = :ended
  end

  def call(force = false)
    cache_recent_stats
    @game.save!
    contests_that_are_waiting_on(@game).each do |contest|
      FinalizeContest.new(contest).call if contest.finalizable?
    end
  end

  private

    def contests_that_are_waiting_on(game)
      game.reverse_league_pick_contests.where(status: nil) + game.contests
    end

    def cache_recent_stats
      worker =
        case game
        when Mlb::Game
          Mlb::CacheRecentStats
        when Nfl::Game
          Nfl::CacheRecentStats
        end

      Background.push worker, @game.players.pluck(:id)
    end

end