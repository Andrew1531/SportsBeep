class Mlb::CacheRecentStats
  include Sidekiq::Worker

  NUM_GAMES = 10

  def perform(player_ids)
    @players = Mlb::Player.where(id: player_ids)
    @players.each do |player|
      games = player.games.reorder(start_time: :desc).uniq.limit(NUM_GAMES).pluck :id
      cache_sums player, games
      cache_averages player, games
    end
  end

  private

    def cache_sums(player, games)
      statdata = (Mlb::EXPANDED_STATS_FOR.(player) - Mlb::AVERAGED_STATS)
      store! player, player.stats.where(game: games, stat: statdata.map(&:id)).group(:stat).order('NULL').sum(:amount)
    end

    def cache_averages(player, games)
      statdata = Mlb::EXPANDED_STATS_FOR.(player) & Mlb::AVERAGED_STATS
      store! player, player.stats.where(game: games, stat: statdata.map(&:id)).group(:stat).order('NULL').average(:amount)
    end

    def store!(player, stats)
      stats.each do |id, value|
        player.recent_stats.store StatData.find(id), value
      end
    end

end