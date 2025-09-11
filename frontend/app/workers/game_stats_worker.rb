class GameStatsWorker
  include Sidekiq::Worker

  protected

    def requeue_or_end_game
      Background.push UpdateCachedTicketScores, @game.id
      @game.update(status: nil) if scheduled?
      if ended?
        EndGame.new(@game).call
      elsif postponed?
        PostponeGame.new(@game).call
      else
        seconds = ENV['MLB_POLLING_INTERVAL'].to_i
        seconds = rand (seconds - 5)..(seconds + 5)
        self.class.perform_in seconds, @game.id unless Rails.env.development?
      end
    end

    def ended?
      status == 'closed'
    end

    def postponed?
      status == 'postponed' || status == 'suspended'
    end

    def scheduled?
      status == 'scheduled'
    end

end