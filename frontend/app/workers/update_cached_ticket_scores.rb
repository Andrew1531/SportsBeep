class UpdateCachedTicketScores
  include Sidekiq::Worker

  def perform(game_id)
    game = Game.find(game_id)
    game.contests.each do |contest|
      ActiveRecord::Base.transaction { cache_scores_and_placings(contest.tickets) }
    end
  end

  private

    # this method needs refactoring
    def cache_scores_and_placings(tickets)
      tickets.each do |ticket|
        ticket.cached_score = ticket.score!
        ticket.cached_best_or_bust_score = ticket.answers.score
      end

      tickets.each do |ticket|
        ticket.cached_placing = tickets.sort_by(&:cached_score).reverse.index(ticket) + 1
      end

      tickets.each do |ticket|
        # validate: false so we dont have to worry about game start time validation
        ticket.save! validate: false
      end
    end

end