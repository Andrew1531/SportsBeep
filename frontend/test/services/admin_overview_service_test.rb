require 'test_helper'

class AdminOverviewServiceTest < ActiveSupport::TestCase
  test 'aggregates every token exactly across sports and only current obligations' do
    alpha = create_token('a', '41', 'ALPHA')
    beta = create_token('b', '42', 'BETA', enabled: false)
    huge = 9_007_199_254_740_993
    account = Account.create!
    AccountTokenBalance.create!(account: account, approved_token: alpha, balance_units: huge, loaded_units: 0)
    AccountTokenBalance.create!(account: account, approved_token: beta, balance_units: 17, loaded_units: 0)

    Wager.insert_all!([
      wager_attributes(alpha.id, 'pending', 'nfl', huge, huge + 11),
      wager_attributes(alpha.id, 'active', 'nba', 7, 13),
      wager_attributes(alpha.id, 'won', 'mlb', 500, 900),
      wager_attributes(beta.id, 'active', 'nhl', 19, 31),
      wager_attributes(nil, 'pending', 'mlb', 2, 3),
      wager_attributes(nil, 'lost', 'mlb', 4, 5)
    ])

    open_contest = insert_contest(nil)
    finalized_contest = insert_contest('finalized')
    Ticket.insert_all!([
      ticket_attributes(alpha.id, open_contest.id, huge),
      ticket_attributes(beta.id, nil, 23),
      ticket_attributes(alpha.id, finalized_contest.id, 100),
      ticket_attributes(nil, open_contest.id, nil)
    ])

    insert_transfer(alpha.id, 'deposit', 'confirmed', huge)
    insert_transfer(alpha.id, 'deposit', 'credited', 100)
    insert_transfer(alpha.id, 'withdrawal', 'submitted', 29)
    insert_transfer(alpha.id, 'withdrawal', 'confirmed', 200)
    insert_transfer(beta.id, 'deposit', 'pending', 37)
    insert_transfer(nil, 'withdrawal', 'unknown', nil)

    snapshot = { lovelace_units: 42, assets: {} }
    received_tokens = nil
    constructor = lambda do
      lambda do |tokens:|
        received_tokens = tokens
        snapshot
      end
    end

    overview = AdminOverviewService.new(snapshot_service: constructor).call
    alpha_row = overview[:tokens].find { |row| row[:token] == alpha }
    beta_row = overview[:tokens].find { |row| row[:token] == beta }

    assert overview[:generated_at].respond_to?(:to_time)
    assert_equal snapshot, overview[:treasury]
    assert_equal [alpha, beta], received_tokens
    assert_equal [alpha, beta], overview[:tokens].map { |row| row[:token] }
    assert_equal huge, alpha_row[:available_units]
    assert_equal huge + 7, alpha_row[:sportsbook_stake_units]
    assert_equal huge + 24, alpha_row[:potential_payout_units]
    assert_equal 2, alpha_row[:open_wager_count]
    assert_equal huge, alpha_row[:fantasy_stake_units]
    assert_equal 1, alpha_row[:active_entry_count]
    assert_equal huge, alpha_row[:pending_deposit_units]
    assert_equal 29, alpha_row[:pending_withdrawal_units]
    assert_equal 19, beta_row[:sportsbook_stake_units]
    assert_equal 23, beta_row[:fantasy_stake_units]
    assert_equal 37, beta_row[:pending_deposit_units]
    assert_equal 3, overview[:legacy_unclassified_count]
  end

  test 'counts only unresolved swaps with exact beep units' do
    user = User.create!(
      email: 'overview-swaps@example.com', username: 'overview-swaps',
      password: 'Password123!', password_confirmation: 'Password123!'
    )
    create_swap(user.id, 'pending', 9_007_199_254_740_993, 1)
    create_swap(user.id, 'confirmed', 7, 2)
    create_swap(user.id, 'paying', 11, 3)
    create_swap(user.id, 'unknown', 13, 4)
    create_swap(user.id, 'paid', 100, 5)
    create_swap(user.id, 'credited', 100, 6)
    create_swap(user.id, 'failed', 100, 7)

    overview = AdminOverviewService.new(snapshot_service: -> { ->(tokens:) { { assets: tokens } } }).call

    assert_equal 4, overview[:unresolved_swap_count]
    assert_equal 9_007_199_254_741_024, overview[:unresolved_swap_beep_units]
  end

  private

  def create_token(policy_character, asset_name, ticker, enabled: true)
    policy = policy_character * 56
    ApprovedToken.create!(
      policy_id: policy, asset_unit: policy + asset_name, display_name: ticker,
      ticker: ticker, decimals: 0, enabled: enabled
    )
  end

  def wager_attributes(token_id, status, sport, amount, payout)
    {
      approved_token_id: token_id, sport: sport, bet_type: 'moneyline', selection: 'A',
      status: status, amount_units: amount, potential_payout_units: payout,
      amount_cents: 0, potential_payout_cents: 0, created_at: Time.current, updated_at: Time.current
    }
  end

  def insert_contest(status)
    Contest.insert_all!([{ status: status, tickets_count: 0, created_at: Time.current, updated_at: Time.current }])
    Contest.order(:id).last
  end

  def ticket_attributes(token_id, contest_id, fee)
    {
      approved_token_id: token_id, contest_id: contest_id, entry_fee_units: fee,
      created_at: Time.current, updated_at: Time.current
    }
  end

  def insert_transfer(token_id, direction, status, amount)
    BeepChainTransfer.insert_all!([{
      user_id: 1, approved_token_id: token_id, direction: direction, status: status,
      amount_beep: amount || 1, amount_units: amount, created_at: Time.current, updated_at: Time.current
    }])
  end

  def create_swap(user_id, status, beep_amount, sequence)
    now = Time.current
    SwapAsset.insert_all!([{
      policy_id: sequence.to_s * 56, asset_unit: sequence.to_s * 56 + '41',
      ticker: "S#{sequence}", decimals: 0, beep_per_asset: 1, enabled: true,
      created_at: now, updated_at: now
    }])
    asset = SwapAsset.order(:id).last
    SwapQuote.insert_all!([{
      user_id: user_id, swap_asset_id: asset.id, amount_units: 1, beep_amount: beep_amount,
      beep_per_asset: 1, expires_at: 1.hour.from_now,
      created_at: now, updated_at: now
    }])
    quote = SwapQuote.order(:id).last
    CardanoSwap.insert_all!([{
      user_id: user_id, swap_asset_id: asset.id, swap_quote_id: quote.id, amount_units: 1,
      beep_amount: beep_amount, payout_method: 'wallet', source_tx_hash: sequence.to_s.rjust(64, '0'),
      status: status, created_at: now, updated_at: now
    }])
  end
end