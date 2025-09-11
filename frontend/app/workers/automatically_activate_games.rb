class AutomaticallyActivateGames
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    hourly.minute_of_hour(30)
  end

  def perform
    games.each do |game|
      logger.info "AutomaticBettableGames - Activating game: #{game.id} #{game.home_team} @ #{game.away_team}"
      BettableGame.new(game).call!
    end
  end

  private

    def games
      Mlb::Game.between(Time.current, 48.hours.from_now).where(bettable: false).uniq + \
        Nfl::Game.between(Time.current, 14.days.from_now).where(bettable: false).uniq
    end

end