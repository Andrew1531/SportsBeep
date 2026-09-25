namespace :fantasy do
  desc 'Set up MLB fantasy game data (game dates, pools, templates, contests)'
  task setup: :environment do
    SportsbookOnly.reject!
    puts 'Setting up fantasy game data...'

    # Fix game dates — spread across next 14 days
    Mlb::Game.all.each_with_index do |g, i|
      hrs = [13, 16, 19, 20, 22][i % 5]
      g.update_columns(start_time: Time.now + (i + 1).days + hrs.hours)
    end
    puts "Games updated: #{Mlb::Game.where('start_time > ?', Time.now).count} future"

    # Create / find pools
    p_free    = Pool.where(prize_pool: 200,  max_tickets_per_contest: 200).first ||
                Pool.create!(prize_pool: 200,  max_tickets_per_contest: 200, entry_fee_multiplier: 0.0)
    p_starter = Pool.where(prize_pool: 500,  max_tickets_per_contest: 50).first ||
                Pool.create!(prize_pool: 500,  max_tickets_per_contest: 50,  entry_fee_multiplier: 1.0)
    p_pro     = Pool.where(prize_pool: 2500, max_tickets_per_contest: 50).first ||
                Pool.create!(prize_pool: 2500, max_tickets_per_contest: 50,  entry_fee_multiplier: 1.0)
    puts "Pools: #{Pool.count}"

    # Create templates + contests for every future MLB game
    games = Mlb::Game.where('start_time > ?', Time.now).to_a
    puts "Creating contests for #{games.size} games..."
    created = 0
    games.each do |game|
      [p_free, p_starter, p_pro].each do |pool|
        unless ContestTemplate.exists?(game_id: game.id, pool_id: pool.id)
          tpl = ContestTemplate.new(game: game, pool: pool, skip_question_validation: true)
          tpl.save!
          created += 1
        end
        tpl = ContestTemplate.find_by!(game_id: game.id, pool_id: pool.id)
        unless Mlb::Contest.exists?(template_id: tpl.id)
          Mlb::Contest.create!(template_id: tpl.id, status: 'open', tickets_count: 0)
        end
      end
    end
    puts "Created #{created} new templates"
    puts "Templates: #{ContestTemplate.count}"
    puts "Contests:  #{Mlb::Contest.count}"
    puts 'Done!'
  end
end
