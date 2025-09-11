class ChangeFinalizedGamesToEndedAndTheirContestsToFinalized < ActiveRecord::Migration
  def change
    games = Game.where(status: :finalized).to_a
    contests = Contest.joins(:game).where(games: { status: :finalized }).to_a
    games.each { |g| g.update status: 'ended' }
    contests.each { |c| c.update status: 'finalized' }
  end
end
