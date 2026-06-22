namespace :wagers do
  desc 'Settle open wagers whose games have completed (grades results & pays out)'
  task settle: :environment do
    settled = 0
    skipped = 0
    no_result = 0

    candidates = Wager.open.game_completed
    puts "Found #{candidates.count} open wager(s) on completed games."

    results = GameResultService.new

    candidates.find_each do |wager|
      score = results.final_score(wager)

      if score.nil?
        no_result += 1
        next
      end

      if wager.settle_with_scores!(score.home_score, score.away_score)
        settled += 1
        puts "  ✓ Wager ##{wager.id} (#{wager.matchup}) → #{wager.status.upcase}"
      else
        skipped += 1
      end
    rescue StandardError => e
      skipped += 1
      Rails.logger.error "Settle error for wager #{wager.id}: #{e.message}"
      puts "  ✗ Wager ##{wager.id} error: #{e.message}"
    end

    puts "Done. Settled: #{settled}, no result available: #{no_result}, skipped: #{skipped}."
  end
end
