class GeneralizeTables < ActiveRecord::Migration
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

    Contest.update_all type: 'Mlb::Contest'
    Game.update_all type: 'Mlb::Game'
    Player.update_all type: 'Mlb::Player'
    Stat.update_all type: 'Mlb::Stat'
    StatTopic.update_all type: 'Mlb::StatTopic'
    Team.update_all type: 'Mlb::Team'
    Ticket.update_all type: 'Mlb::Ticket'

  end

  private

    def make_sti(table)
      new_table = table.to_s.gsub('mlb_', '').intern
      rename_table table, new_table
      add_column new_table, :type, :string
    end

end
