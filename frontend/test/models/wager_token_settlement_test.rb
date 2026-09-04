require 'test_helper'

class WagerTokenSettlementTest < ActiveSupport::TestCase
  setup do
    policy = 'd' * 56
    @token_a = ApprovedToken.create!(
      policy_id: policy, asset_unit: policy + '41', display_name: 'Alpha',
      ticker: "A#{SecureRandom.hex(3)}", decimals: 2, enabled: true
    )
    @token_b = ApprovedToken.create!(
      policy_id: policy, asset_unit: policy + '42', display_name: 'Beta',
      ticker: "B#{SecureRandom.hex(3)}", decimals: 2, enabled: true
    )
    @user = User.create!(
      email: "token-wager-#{SecureRandom.hex(4)}@example.com",
      password: 'Password123!', password_confirmation: 'Password123!',
      username: "tokenplayer#{SecureRandom.hex(3)}",
      first_name: 'Token', last_name: 'Player'
    )
    @user.account.token_balance_for(@token_a).update!(balance_units: 1_000)
    @user.account.token_balance_for(@token_b).update!(balance_units: 700)
  end

  test 'debits only the selected token' do
    bet = build_wager
    bet.save!
    bet.debit_user_account!

    assert_equal 875, @user.account.token_balance_for(@token_a).reload.balance_units
    assert_equal 700, @user.account.token_balance_for(@token_b).reload.balance_units
  end

  test 'credits wins and pushes only in the wager token' do
    won = build_wager(odds: 100)
    won.save!
    won.debit_user_account!
    assert won.settle_with_scores!(2, 1)
    assert_equal 1_125, @user.account.token_balance_for(@token_a).reload.balance_units
    assert_equal 700, @user.account.token_balance_for(@token_b).reload.balance_units

    pushed = build_wager(odds: -110)
    pushed.save!
    pushed.debit_user_account!
    assert pushed.settle_with_scores!(1, 1)
    assert_equal 1_125, @user.account.token_balance_for(@token_a).reload.balance_units
    assert_equal 700, @user.account.token_balance_for(@token_b).reload.balance_units
  end

  test 'rejects disabled tokens for new wagers' do
    @token_a.update!(enabled: false)
    bet = build_wager

    assert bet.invalid?
    assert_includes bet.errors[:approved_token], 'must be an enabled approved token'
  end

  private

  def build_wager(odds: 100)
    Wager.new(
      user: @user, approved_token: @token_a, amount_units: 125, amount_cents: 0,
      sport: 'mlb', bet_type: 'moneyline', selection: 'Home', home_team: 'Home',
      away_team: 'Away', odds: odds, status: 'pending'
    )
  end
end