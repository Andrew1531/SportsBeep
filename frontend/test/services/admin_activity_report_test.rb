require 'test_helper'

class AdminActivityReportTest < ActiveSupport::TestCase
  setup do
    @token_a = token('a', '41', 'ACTA')
    @token_b = token('b', '42', 'ACTB')
    @user_a = user('activity-a')
    @user_b = user('activity-b')
    balance(@user_a, @token_a, 9_007_199_254_740_993)
    balance(@user_b, @token_a, 25)
    balance(@user_b, @token_b, 800)
  end

  test 'uses exact integers and keeps token, open, closed, balance and stake groupings separate' do
    insert_wager(@user_a, @token_a, 'pending', 101, 250)
    insert_wager(@user_a, @token_a, 'won', 999, 2_000)
    insert_wager(@user_b, @token_a, 'active', 60, 110)
    insert_wager(@user_b, @token_b, 'pending', 700, 900)
    open_contest = insert_contest(nil)
    closed_contest = insert_contest('finalized')
    insert_ticket(@user_a, @token_a, open_contest, 33)
    insert_ticket(@user_a, @token_a, closed_contest, 1_000)
    insert_ticket(@user_b, @token_b, open_contest, 444)

    report = AdminActivityReport.new(token: @token_a.id).call

    assert_equal 9_007_199_254_741_018, report[:totals][:available_units]
    assert_equal 161, report[:totals][:open_wager_stake]
    assert_equal 360, report[:totals][:open_potential_payout]
    assert_equal 33, report[:totals][:active_entry_stake]
    assert_equal 1, report[:totals][:active_entry_count]
    assert_equal [@user_a.id, @user_b.id], report[:balance_leaders].map { |row| row[:user].id }
    assert_equal 101, report[:stake_leaders].find { |row| row[:user] == @user_a }[:wager_units]
    assert_equal 60, report[:stake_leaders].find { |row| row[:user] == @user_b }[:wager_units]
    assert_equal 3, report[:wager_count]
  end

  test 'filters by player search team game status and sport and paginates by 25' do
    26.times { insert_wager(@user_a, @token_a, 'pending', 1, 2, game_id: 'game-7', home_team: 'New York Owls') }
    insert_wager(@user_b, @token_a, 'active', 9, 12, game_id: 'other', home_team: 'Elsewhere')

    first = AdminActivityReport.new(token: @token_a.id, search: @user_a.email, team: 'owls',
                                    game_id: 'game-7', status: 'pending', sport: 'mlb').call
    second = AdminActivityReport.new(token: @token_a.id, user_id: @user_a.id, page: 2).call

    assert_equal 26, first[:wager_count]
    assert_equal 25, first[:wagers].length
    assert_equal 1, second[:wagers].length
  end

  test 'legacy rows remain separately discoverable as unknown cents' do
    insert_wager(@user_a, nil, 'pending', 77, 120, legacy: true)

    report = AdminActivityReport.new(token: 'legacy').call

    assert report[:legacy]
    assert_nil report[:selected_token]
    assert_equal 77, report[:totals][:open_wager_stake]
    assert_equal 1, report[:wager_count]
  end

  private

  def token(letter, suffix, ticker)
    policy = letter * 56
    ApprovedToken.create!(policy_id: policy, asset_unit: policy + suffix, display_name: ticker, ticker: ticker, decimals: 0)
  end

  def user(name)
    User.create!(username: name, email: "#{name}@example.test", password: 'test-password-123',
                 password_confirmation: 'test-password-123', confirmed_at: Time.current)
  end

  def balance(user, token, units)
    AccountTokenBalance.create!(account: user.account, approved_token: token, balance_units: units, loaded_units: units)
  end

  def insert_wager(user, token, status, stake, payout, game_id: 'g1', home_team: 'Home', legacy: false)
    Wager.insert_all!([{
      user_id: user.id, approved_token_id: token&.id, sport: 'mlb', fixture_id: game_id,
      game_id: game_id, home_team: home_team, away_team: 'Away', game_start_time: 1.day.from_now,
      bet_type: 'moneyline', selection: home_team, odds: -110, status: status,
      amount_units: legacy ? nil : stake, potential_payout_units: legacy ? nil : payout,
      amount_cents: legacy ? stake : 0, potential_payout_cents: legacy ? payout : 0,
      created_at: Time.current, updated_at: Time.current
    }])
  end

  def insert_contest(status)
    Contest.insert_all!([{ status: status, tickets_count: 0, created_at: Time.current, updated_at: Time.current }])
    Contest.order(:id).last
  end

  def insert_ticket(user, token, contest, fee)
    Ticket.insert_all!([{
      user_id: user.id, contest_id: contest.id, approved_token_id: token.id, entry_fee_units: fee,
      cached_score: 0, created_at: Time.current, updated_at: Time.current
    }])
  end
end