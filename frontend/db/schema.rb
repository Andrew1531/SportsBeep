# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2026_02_18_100000) do

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "balance_cents", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "clearing_expense_cents", default: 0
    t.integer "promo_balance_cents", default: 0
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "user_id"
    t.string "line_one", default: ""
    t.string "line_two", default: ""
    t.string "city", default: ""
    t.string "state", default: ""
    t.string "zip", default: ""
    t.string "country", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "administrators", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_administrators_on_email", unique: true
  end

  create_table "contest_template_questions", force: :cascade do |t|
    t.integer "contest_template_id"
    t.integer "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contest_template_id"], name: "index_contest_template_questions_on_contest_template_id"
    t.index ["question_id"], name: "index_contest_template_questions_on_question_id"
  end

  create_table "contest_templates", force: :cascade do |t|
    t.integer "game_id"
    t.integer "pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_contest_templates_on_game_id"
    t.index ["pool_id"], name: "index_contest_templates_on_pool_id"
  end

  create_table "contests", force: :cascade do |t|
    t.integer "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tickets_count", default: 0
    t.string "type"
    t.string "status"
    t.index ["template_id"], name: "index_contests_on_template_id"
  end

  create_table "facebook_auths", force: :cascade do |t|
    t.integer "user_id"
    t.string "uid", null: false
    t.string "email", null: false
    t.text "profile_picture"
    t.text "auth_token", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_facebook_auths_on_email"
    t.index ["uid"], name: "index_facebook_auths_on_uid"
    t.index ["user_id", "uid"], name: "index_facebook_auths_on_user_id_and_uid", unique: true
    t.index ["user_id"], name: "index_facebook_auths_on_user_id"
  end

  create_table "favorite_teams", force: :cascade do |t|
    t.integer "user_id"
    t.integer "baseball_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["baseball_id"], name: "index_favorite_teams_on_baseball_id"
    t.index ["user_id"], name: "index_favorite_teams_on_user_id"
  end

  create_table "game_league_picks", force: :cascade do |t|
    t.integer "game_id"
    t.integer "league_pick_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_game_league_picks_on_game_id"
    t.index ["league_pick_id"], name: "index_game_league_picks_on_league_pick_id"
  end

  create_table "game_pools", force: :cascade do |t|
    t.integer "game_id"
    t.integer "pool_id"
    t.integer "max_contests"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_game_pools_on_game_id"
    t.index ["pool_id"], name: "index_game_pools_on_pool_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "external_id"
    t.boolean "bettable", default: false
    t.datetime "start_time"
    t.string "status"
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "season_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
    t.integer "week"
    t.index ["away_team_id"], name: "index_games_on_away_team_id"
    t.index ["home_team_id"], name: "index_games_on_home_team_id"
    t.index ["season_id"], name: "index_games_on_season_id"
  end

  create_table "gl_accounts", force: :cascade do |t|
    t.string "name"
    t.integer "balance_cents", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lineup_positions", force: :cascade do |t|
    t.integer "game_id"
    t.integer "player_id"
    t.string "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_lineup_positions_on_game_id"
    t.index ["player_id"], name: "index_lineup_positions_on_player_id"
  end

  create_table "mlb_seasons", force: :cascade do |t|
    t.string "external_id"
    t.integer "year"
    t.string "type"
    t.boolean "current"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: :cascade do |t|
    t.integer "team_id"
    t.string "external_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "number"
    t.string "bats"
    t.string "throws"
    t.string "status"
    t.string "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
    t.string "headshot"
    t.boolean "on_current_roster", default: false, null: false
    t.index ["team_id"], name: "index_players_on_team_id"
    t.index ["updated_at"], name: "index_players_on_updated_at"
  end

  create_table "pools", force: :cascade do |t|
    t.integer "prize_pool"
    t.integer "max_tickets_per_contest"
    t.float "entry_fee_multiplier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "default", default: false
    t.integer "max_contests"
  end

  create_table "promo_codes", force: :cascade do |t|
    t.string "code"
    t.string "note"
    t.integer "users_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_answers", force: :cascade do |t|
    t.integer "question_id"
    t.integer "answer_id"
    t.integer "ticket_id"
    t.float "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["answer_id"], name: "index_question_answers_on_answer_id"
    t.index ["question_id"], name: "index_question_answers_on_question_id"
    t.index ["ticket_id"], name: "index_question_answers_on_ticket_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "type"
    t.string "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "topic_id"
    t.index ["topic_id"], name: "index_questions_on_topic_id"
  end

  create_table "recent_stats", force: :cascade do |t|
    t.integer "player_id"
    t.string "name"
    t.float "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "points"
    t.integer "stat"
    t.index ["player_id"], name: "index_recent_stats_on_player_id"
  end

  create_table "seasonal_stats", force: :cascade do |t|
    t.integer "player_id"
    t.integer "season"
    t.string "name"
    t.float "amount"
    t.float "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "stat"
    t.index ["player_id"], name: "index_seasonal_stats_on_player_id"
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "require_promo_code_on_signup", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sportsbeep_special_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "authentication_token"
    t.datetime "destroyed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_sportsbeep_special_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_sportsbeep_special_users_on_reset_password_token", unique: true
  end

  create_table "stat_topics", force: :cascade do |t|
    t.string "stat"
    t.string "comparison"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
  end

  create_table "stats", force: :cascade do |t|
    t.integer "player_id"
    t.integer "game_id"
    t.string "name"
    t.float "amount"
    t.float "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "team_id"
    t.string "type"
    t.integer "stat"
    t.index ["game_id"], name: "index_stats_on_game_id"
    t.index ["player_id"], name: "index_stats_on_player_id"
    t.index ["team_id"], name: "index_stats_on_team_id"
  end

  create_table "team_game_stats", force: :cascade do |t|
    t.integer "team_id"
    t.integer "game_id"
    t.float "amount"
    t.float "points"
    t.string "type"
    t.integer "stat"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_team_game_stats_on_game_id"
    t.index ["team_id"], name: "index_team_game_stats_on_team_id"
  end

  create_table "team_stats", force: :cascade do |t|
    t.integer "team_id"
    t.integer "season"
    t.string "name"
    t.float "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "stat"
    t.index ["team_id"], name: "index_team_stats_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "external_id"
    t.string "abbr"
    t.string "name"
    t.string "market"
    t.string "league"
    t.string "division"
    t.string "primary_color"
    t.string "secondary_color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
    t.string "conference"
  end

  create_table "ticket_players", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "position"
    t.index ["player_id"], name: "index_ticket_players_on_player_id"
    t.index ["ticket_id"], name: "index_ticket_players_on_ticket_id"
  end

  create_table "ticket_squads", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "team_id"
    t.string "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id"], name: "index_ticket_squads_on_team_id"
    t.index ["ticket_id"], name: "index_ticket_squads_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "contest_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "league_pick_game_id"
    t.integer "league_pick_team_id"
    t.integer "placing"
    t.string "type"
    t.float "cached_score", default: 0.0
    t.integer "cached_placing"
    t.float "cached_best_or_bust_score", default: 0.0
    t.index ["contest_id"], name: "index_tickets_on_contest_id"
    t.index ["league_pick_game_id"], name: "index_tickets_on_league_pick_game_id"
    t.index ["league_pick_team_id"], name: "index_tickets_on_league_pick_team_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "timer_states", force: :cascade do |t|
    t.integer "ticket_id"
    t.string "encrypted_text"
    t.float "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ticket_id"], name: "index_timer_states_on_ticket_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount_cents", default: 0
    t.string "description"
    t.string "status"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "account_id"
    t.index ["account_id"], name: "index_transactions_on_account_id"
  end

  create_table "twitter_auths", force: :cascade do |t|
    t.integer "user_id"
    t.string "uid", null: false
    t.string "username", null: false
    t.text "auth_token", null: false
    t.text "auth_secret", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_twitter_auths_on_uid"
    t.index ["user_id", "uid"], name: "index_twitter_auths_on_user_id_and_uid", unique: true
    t.index ["user_id"], name: "index_twitter_auths_on_user_id"
    t.index ["username"], name: "index_twitter_auths_on_username"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "full_name"
    t.string "email", default: "", null: false
    t.date "date_of_birth"
    t.string "gender"
    t.boolean "private", default: false
    t.string "avatar"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "authentication_token"
    t.datetime "destroyed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "can_distribute"
    t.string "username"
    t.integer "user_id"
    t.string "device_token"
    t.string "platform"
    t.string "ancestry"
    t.datetime "became_agent_at"
    t.integer "promo_code_id"
    t.boolean "avatar_processing", default: false, null: false
    t.string "avatar_uuid"
    t.string "cardano_wallet_address"
    t.string "ethereum_wallet_address"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["promo_code_id"], name: "index_users_on_promo_code_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_id"], name: "index_users_on_user_id"
  end

  create_table "wagers", force: :cascade do |t|
    t.integer "user_id"
    t.string "sport", null: false
    t.string "league"
    t.string "fixture_id"
    t.string "game_id"
    t.string "home_team"
    t.string "away_team"
    t.datetime "game_start_time"
    t.string "bet_type", null: false
    t.string "selection", null: false
    t.string "selection_detail"
    t.decimal "odds", precision: 10, scale: 2
    t.decimal "points", precision: 5, scale: 1
    t.integer "amount_cents", default: 0, null: false
    t.integer "potential_payout_cents", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.string "result"
    t.string "sportsbook"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sport"], name: "index_wagers_on_sport"
    t.index ["status"], name: "index_wagers_on_status"
    t.index ["user_id", "status"], name: "index_wagers_on_user_id_and_status"
    t.index ["user_id"], name: "index_wagers_on_user_id"
  end

end
