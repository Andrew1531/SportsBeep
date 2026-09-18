require 'test_helper'

class AdminRecordsTest < ActionDispatch::IntegrationTest
  setup do
    https!
    @admin = Administrator.create!(
      email: 'records-admin@example.test', password: 'password123', password_confirmation: 'password123'
    )
    @user = User.create!(
      email: 'records-wallet@example.test', username: 'records-wallet', password: 'password123',
      cardano_wallet_address: 'addr1_test_display_wallet', cardano_wallet_name: 'Test wallet',
      cardano_wallet_verified_at: Time.current
    )
    @other_user = User.create!(
      email: 'records-other@example.test', username: 'records-other', password: 'password123',
      cardano_wallet_address: 'addr1_other_display_wallet'
    )
    @asset = SwapAsset.create!(asset_unit: 'lovelace', ticker: 'ADA', decimals: 6, beep_per_asset: 10)
    @quote = SwapQuote.create!(
      user: @user, swap_asset: @asset, amount_units: 1_234_567, beep_amount: 12,
      beep_per_asset: 10, expires_at: 1.hour.from_now
    )
    @swap = CardanoSwap.create!(
      user: @user, swap_asset: @asset, swap_quote: @quote, amount_units: 1_234_567,
      beep_amount: 12, payout_method: 'game_balance', status: 'credited', source_tx_hash: 'a' * 64
    )
  end

  test 'new financial records routes deny anonymous and ordinary users' do
    paths = ['/admin/wallets', "/admin/wallets/#{@user.id}", '/admin/swaps', "/admin/swaps/#{@swap.id}", '/admin/financials']
    paths.each do |path|
      get path
      assert_redirected_to new_administrator_session_path
      assert_includes response.headers['Cache-Control'], 'no-store'
    end
    sign_in @user
    paths.each do |path|
      get path
      assert_redirected_to new_administrator_session_path
    end
  end

  test 'wallet directory searches owners and filters verification' do
    sign_in @admin
    get admin_wallets_path, params: { search: @user.email, verification: 'verified' }
    assert_response :success
    assert_includes response.body, 'addr1_test_display_wallet'
    refute_includes response.body, 'addr1_other_display_wallet'
    get admin_wallets_path, params: { verification: 'unverified' }
    assert_response :success
    assert_includes response.body, 'addr1_other_display_wallet'
    refute_includes response.body, 'addr1_test_display_wallet'
    get admin_wallets_path, params: { search: 'no-wallet-matches-this' }
    assert_includes response.body, 'No wallet records match'
  end

  test 'wallet details include retained destinations and exact token balances' do
    sign_in @admin
    token = ApprovedToken.create!(
      asset_unit: ('e' * 56) + '01', policy_id: 'e' * 56,
      ticker: 'REC', display_name: 'Records test token', decimals: 0, enabled: true
    )
    @user.account.token_balance_for(token).update!(balance_units: 9_007_199_254_740_993)
    BeepChainTransfer.create!(
      user: @user, approved_token: token, direction: 'withdrawal', amount_beep: 1,
      amount_units: 1, status: 'confirmed', request_key: 'records-transfer',
      destination_address: 'addr1_historical_destination', tx_hash: 'b' * 64
    )
    get admin_wallet_path(@user)
    assert_response :success
    assert_includes response.body, '9007199254740993'
    assert_includes response.body, 'addr1_historical_destination'
    assert_includes response.body, 'cardanoscan.io/transaction/'
    assert_includes response.headers['X-Robots-Tag'], 'noindex'
  end

  test 'swap history filters and presents both raw and formatted quantities' do
    sign_in @admin
    get admin_swaps_path, params: { status: 'credited', swap_asset_id: @asset.id, search: @user.email }
    assert_response :success
    assert_includes response.body, '1.234567'
    assert_includes response.body, '1234567'
    assert_includes response.body, @user.email
    get admin_swaps_path, params: { status: 'unknown' }
    assert_response :success
    assert_includes response.body, 'No swap records match'
    get admin_swaps_path, params: { user_id: @other_user.id }
    assert_includes response.body, 'No swap records match'
  end

  test 'swap detail keeps accepted rate and exposes transaction links without mutations' do
    sign_in @admin
    @asset.update!(beep_per_asset: 999)
    get admin_swap_path(@swap)
    assert_response :success
    assert_includes response.body, '10.0 BEEP per input token'
    assert_includes response.body, @swap.source_explorer_url
    assert_includes response.body, 'lovelace'
    assert_equal 'credited', @swap.reload.status
    assert_includes response.headers['Cache-Control'], 'no-store'
  end
end