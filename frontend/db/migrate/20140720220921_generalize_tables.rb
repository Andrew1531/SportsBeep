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
    Contest.update_all type: 'Mlb::Contest' if Contest.count > 0 rescue nil
    Game.update_all type: 'Mlb::Game' if Game.count > 0 rescue nil
    Player.update_all type: 'Mlb::Player' if Player.count > 0 rescue nil
    Stat.update_all type: 'Mlb::Stat' if Stat.count > 0 rescue nil
    StatTopic.update_all type: 'Mlb::StatTopic' if StatTopic.count > 0 rescue nil
    Team.update_all type: 'Mlb::Team' if Team.count > 0 rescue nil
    Ticket.update_all type: 'Mlb::Ticket' if Ticket.count > 0 rescue nil

  end

  private

    def make_sti(table)
      new_table = table.to_s.gsub('mlb_', '').intern
      rename_table table, new_table
      add_column new_table, :type, :string
    end

end
