class Nfl::SeasonalStatsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(12) }

  def perform
    Nfl::Team.pluck(:external_id).each do |id|
      Background.push TeamSeasonalStatWorker, id
    end
  end

  class TeamSeasonalStatWorker
    include Sidekiq::Worker
    include SportsData::Nfl::Client

    def perform(id)
      @data = get("teams/#{id}/#{year}/#{season}/statistics.json")
      team = Nfl::Team.find_by(external_id: id)

      passing_yards = @data.drill('statistics.passing.yds')
      rushing_yards = @data.drill('statistics.rushing.yds')
      games_played = team.stats[Nfl::Stats::GAMES]
      games_played = 1 if games_played.zero?
      team.stats.store Nfl::Stats::OFFENSIVE_YPG, (passing_yards + rushing_yards) / games_played
      team.stats.store Nfl::Stats::PASSING_YPG, passing_yards / games_played
      team.stats.store Nfl::Stats::RUSHING_YPG, rushing_yards / games_played
      team.stats.store Nfl::Stats::INTERCEPTIONS_PG, @data.drill('statistics.defense.int') / games_played

      @data['players'].each do |json|
        next unless player = Nfl::Player.find_by(external_id: json['id'])
        stats = player.seasonal_stats
        SportsData::Nfl::Parser.new(json['statistics'], stats).parse
      end
    end
  end

end