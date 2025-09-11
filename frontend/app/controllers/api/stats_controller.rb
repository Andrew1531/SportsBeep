class Api::StatsController < Api::BaseController

  before_action :set_player

  def index
    @season_stats = []
    @recent_stats = []
    stats = _sport::EXPANDED_STATS_FOR.(@player)
    # load these relations so lookup using fetch() later is faster
    @player.seasonal_stats.where(stat: stats)
    @player.recent_stats.where(stat: stats)
    # use fetch to populate instance vars, since it will load NullStat where necessary
    stats.each do |statdata|
      @season_stats << @player.seasonal_stats.fetch(statdata)
      @recent_stats << @player.recent_stats.fetch(statdata)
    end
    fresh_when [@season_stats, @recent_stats]
  end

  private

    def set_player
      @player = Player.find(params[:player_id])
    end

end
