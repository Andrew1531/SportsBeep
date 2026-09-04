require 'test_helper'

class SwapAssetTest < ActiveSupport::TestCase
  setup { SwapAsset.where(asset_unit: 'lovelace').delete_all }

  test 'accepts ADA only as lovelace and native assets only as complete matching units' do
    assert SwapAsset.new(asset_unit: 'lovelace', ticker: 'ADA', decimals: 6, beep_per_asset: 4).valid?
    assert SwapAsset.new(asset_unit: 'a' * 56, policy_id: 'a' * 56, ticker: 'BAD', decimals: 0, beep_per_asset: 1).invalid?
    assert SwapAsset.new(asset_unit: ('a' * 56) + '4f', policy_id: 'b' * 56, ticker: 'BAD2', decimals: 0, beep_per_asset: 1).invalid?
    assert SwapAsset.new(asset_unit: ('a' * 56) + '4f', policy_id: 'a' * 56, ticker: 'GOOD', decimals: 0, beep_per_asset: 1).valid?
  end

  test 'uses integer smallest units without rounding' do
    asset = SwapAsset.new(asset_unit: 'lovelace', ticker: 'ADA', decimals: 6, beep_per_asset: 5)
    assert_equal 1_250_000, asset.parse_amount!('1.25')
    assert_equal '1.25', asset.format_units(1_250_000)
    assert_raises(TokenAmount::InvalidAmount) { asset.parse_amount!('1.0000001') }
  end

  test 'quote retains its locked rate and expires' do
    user = User.create!(email: "quote-#{SecureRandom.hex(4)}@example.com", password: 'Password123!', password_confirmation: 'Password123!', username: "quote#{SecureRandom.hex(3)}", first_name: 'Quote', last_name: 'User')
    asset = SwapAsset.create!(asset_unit: 'lovelace', ticker: 'ADA', decimals: 6, beep_per_asset: 5)
    quote = user.swap_quotes.create!(swap_asset: asset, amount_units: 1_500_000, beep_amount: 7, beep_per_asset: 5, expires_at: 4.minutes.from_now)
    asset.update!(beep_per_asset: 9)
    assert_equal BigDecimal('5'), quote.reload.beep_per_asset
    assert quote.active?
    quote.update_column(:expires_at, 1.second.ago)
    refute quote.active?
  end
end