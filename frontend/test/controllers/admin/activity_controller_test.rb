require 'test_helper'

class Admin::ActivityControllerTest < ActionDispatch::IntegrationTest
  setup do
    https!
    policy = 'c' * 56
    @token = ApprovedToken.create!(policy_id: policy, asset_unit: policy + '43', display_name: 'Activity Coin', ticker: 'ACTC', decimals: 2)
    @player = User.create!(username: 'activity-player', email: 'activity-player@example.test',
                           password: 'test-password-123', password_confirmation: 'test-password-123',
                           confirmed_at: Time.current)
    Wager.insert_all!([{
      user_id: @player.id, approved_token_id: @token.id, sport: 'nfl', fixture_id: 'fixture-detail',
      game_id: 'game-detail', home_team: 'Home', away_team: 'Away', bet_type: 'spread',
      selection: 'Away', points: 3.5, odds: -110, status: 'pending', amount_units: 125,
      potential_payout_units: 240, amount_cents: 0, potential_payout_cents: 0,
      created_at: Time.current, updated_at: Time.current
    }])
    @wager = Wager.find_by!(fixture_id: 'fixture-detail')
  end

  test 'anonymous and player cannot access activity intelligence' do
    get admin_activity_path
    assert_redirected_to new_administrator_session_path

    sign_in @player
    get admin_activity_path
    assert_redirected_to new_administrator_session_path
  end

  test 'administrator sees filtered report and wager drilldown' do
    sign_in administrator
    get admin_activity_path, params: { token: @token.id, game_id: 'game-detail' }
    assert_response :success
    assert_includes response.body, 'Game activity intelligence'
    assert_includes response.body, 'fixture-detail'
    assert_includes response.body, '125 raw'

    get admin_activity_wager_path(@wager)
    assert_response :success
    assert_includes response.body, 'Sportsbook wager'
    assert_includes response.body, 'activity-player@example.test'
    assert_includes response.body, @token.asset_unit
  end

  test 'administrator sees fantasy entry picks and cached scoring details' do
    home = Team.create!(name: 'Home Club', abbr: 'HOM', external_id: 'home-activity')
    away = Team.create!(name: 'Away Club', abbr: 'AWY', external_id: 'away-activity')
    game = Game.create!(home_team: home, away_team: away, start_time: 1.day.from_now)
    pool = Pool.create!(prize_pool: 100, max_tickets_per_contest: 10, entry_fee_multiplier: 1)
    template = ContestTemplate.new(game: game, pool: pool)
    template.skip_question_validation = true
    template.save!
    contest = Contest.create!(template: template, status: nil)
    Ticket.insert_all!([{
      user_id: @player.id, contest_id: contest.id, approved_token_id: @token.id,
      entry_fee_units: 350, cached_score: 12.5, cached_placing: 2,
      created_at: Time.current, updated_at: Time.current
    }])
    ticket_id = Ticket.where(user_id: @player.id, contest_id: contest.id).pick(:id)

    sign_in administrator
    get admin_activity_entry_path(ticket_id)

    assert_response :success
    assert_includes response.body, 'Fantasy entry'
    assert_includes response.body, 'Home Club'
    assert_includes response.body, '12.5'
    assert_includes response.body, 'No answers recorded'
  end

  private

  def administrator
    @administrator ||= Administrator.create!(email: 'activity-admin@example.test',
                                              password: 'test-password-123',
                                              password_confirmation: 'test-password-123')
  end
end