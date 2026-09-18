require 'test_helper'

class AdminFinancialReportTest < ActiveSupport::TestCase
  test 'keeps exact large integer balances and wagers grouped per token' do
    policy_a = 'a' * 56
    policy_b = 'b' * 56
    token_a = ApprovedToken.create!(policy_id: policy_a, asset_unit: policy_a + '41', display_name: 'Alpha', ticker: 'ALPHA', decimals: 0)
    token_b = ApprovedToken.create!(policy_id: policy_b, asset_unit: policy_b + '42', display_name: 'Beta', ticker: 'BETA', decimals: 6, enabled: false)
    huge = 9_007_199_254_740_993

    account = Account.create!
    AccountTokenBalance.create!(account: account, approved_token: token_a, balance_units: huge, loaded_units: huge - 1)
    AccountTokenBalance.create!(account: account, approved_token: token_b, balance_units: 17, loaded_units: 8)
    Wager.insert_all!([
      wager_attributes(token_a, 'pending', huge, huge + 10),
      wager_attributes(token_b, 'active', 7, 12),
      wager_attributes(token_a, 'won', 100, 250),
      wager_attributes(token_a, 'push', 40, 80),
      wager_attributes(token_a, 'lost', 20, 90)
    ])

    report = AdminFinancialReport.new.call
    alpha = report[:tokens].find { |row| row[:token] == token_a }
    beta = report[:tokens].find { |row| row[:token] == token_b }

    assert_equal huge, alpha[:available_balance_units]
    assert_equal huge - 1, alpha[:loaded_units]
    assert_equal huge, alpha[:open_wagers]['pending'][:stake_units]
    assert_equal 7, beta[:open_wagers]['active'][:stake_units]
    assert_equal 250, alpha[:settled_wagers]['won'][:payout_units]
    assert_equal 40, alpha[:settled_wagers]['push'][:payout_units]
    assert_equal 0, alpha[:settled_wagers]['lost'][:payout_units]
  end

  private

  def wager_attributes(token, status, amount, payout)
    {
      approved_token_id: token.id, sport: 'mlb', bet_type: 'moneyline', selection: 'A',
      status: status, amount_units: amount, potential_payout_units: payout,
      amount_cents: 0, potential_payout_cents: 0, created_at: Time.current, updated_at: Time.current
    }
  end
end