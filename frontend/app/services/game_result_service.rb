# Fetches final scores for completed games so wagers can be settled.
#
# This is the single integration point for live results. Today it queries
# OpticOdds (the same provider used for odds); when that key gains results
# permissions, settlement starts working automatically with no other changes.
# Any provider can be added in #fetch_scores as long as it returns a hash of
# { home_score:, away_score: } or nil when no final score is available.
class GameResultService
  Result = Struct.new(:home_score, :away_score, keyword_init: true)

  def initialize
    @optic = OpticOddsService.new
  end

  # Returns a Result with final scores, or nil if the game is not final / no
  # data is available. Never raises — settlement must degrade gracefully.
  def final_score(wager)
    scores = fetch_scores(wager)
    return nil unless scores
    home = scores[:home_score]
    away = scores[:away_score]
    return nil if home.nil? || away.nil?
    Result.new(home_score: home.to_i, away_score: away.to_i)
  rescue StandardError => e
    Rails.logger.error "GameResultService error for wager #{wager.id}: #{e.message}"
    nil
  end

  private

  def fetch_scores(wager)
    return nil if wager.fixture_id.blank?
    @optic.fixture_results(wager.fixture_id)
  end
end
