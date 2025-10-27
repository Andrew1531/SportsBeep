class GeneralizeTables < ActiveRecord::Migration[4.2]
  def change
    rename_table :mlb_questions, :questions
    rename_table :mlb_contest_templates, :contest_templates
    rename_table :mlb_contest_template_questions, :contest_template_questions
    rename_table :mlb_game_league_picks, :game_league_picks
    rename_table :mlb_game_pools, :game_pools
    rename_table :mlb_pools, :pools
    rename_table :mlb_question_answers, :question_answers
    rename_table :mlb_recent_stats, :recent_stats
    rename_table :mlb_seasonal_stats, :seasonal_stats
    rename_table :mlb_team_stats, :team_stats
    rename_table :mlb_ticket_players, :ticket_players
    rename_table :mlb_timer_states, :timer_states
    make_sti :mlb_contests
    make_sti :mlb_games
    make_sti :mlb_players
    make_sti :mlb_stats
    make_sti :mlb_stat_topics
    make_sti :mlb_teams
    make_sti :mlb_tickets

    # Only update existing records - skip if tables are empty (fresh database)
    execute "UPDATE contests SET type = 'Mlb::Contest' WHERE type IS NULL" rescue nil
    execute "UPDATE games SET type = 'Mlb::Game' WHERE type IS NULL" rescue nil
    execute "UPDATE players SET type = 'Mlb::Player' WHERE type IS NULL" rescue nil
    execute "UPDATE stats SET type = 'Mlb::Stat' WHERE type IS NULL" rescue nil
    execute "UPDATE stat_topics SET type = 'Mlb::StatTopic' WHERE type IS NULL" rescue nil
    execute "UPDATE teams SET type = 'Mlb::Team' WHERE type IS NULL" rescue nil
    execute "UPDATE tickets SET type = 'Mlb::Ticket' WHERE type IS NULL" rescue nil

  end

  private

    def make_sti(table)
      new_table = table.to_s.gsub('mlb_', '').intern
      rename_table table, new_table
      add_column new_table, :type, :string
    end

end
