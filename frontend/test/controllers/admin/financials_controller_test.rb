require 'test_helper'
require 'minitest/mock'

class Admin::FinancialsControllerTest < ActionDispatch::IntegrationTest
  test 'anonymous visitor cannot access the financial overview' do
    get '/admin/financials'
    assert_redirected_to new_administrator_session_path
  end

  test 'administrator sees read-only ledger and treasury distinction' do
    admin = Administrator.create!(email: 'financial-admin@example.test', password: 'test-password-123', password_confirmation: 'test-password-123')
    sign_in admin
    snapshot_service = Struct.new(:snapshot) {
      def call(tokens:)
        snapshot
      end
    }.new({ address: nil, checked_at: nil, stale: true, error: 'BLOCKFROST_PROJECT_ID is not configured.', lovelace_units: nil, assets: {} })
    TreasurySnapshotService.stub(:new, -> { snapshot_service }) do
      get '/admin/financials'
    end

    assert_response :success
    assert_includes response.body, 'application ledger'
    assert_includes response.body, 'Cardano mainnet treasury wallet detail'
    assert_includes response.body, 'read-only'
  end

  test 'treasury leads with wallet amounts and preserves raw and configured values' do
    token = treasury_token
    render_treasury(token, raw_units: 1_000_000, registry_decimals: 6)

    assert_response :success
    assert_select '.treasury-wallet-amount', text: '21.15508 ADA', count: 2
    assert_select '.treasury-wallet-amount', text: '1 BEEP', count: 2
    assert_select 'details', text: /1,000,000/
    assert_includes response.body, '1000000 (0 decimals)'
    assert_includes response.body, 'WARNING mismatch'
    assert_equal 0, token.reload.decimals
  end

  test 'missing registry decimals never fall back to app-configured wallet amounts' do
    render_treasury(treasury_token, raw_units: 1_000_000, registry_decimals: nil)

    assert_response :success
    assert_includes response.body, 'Wallet amount unavailable'
    assert_select '.treasury-wallet-amount', text: /BEEP/, count: 0
    assert_includes response.body, '1,000,000'
  end

  test 'wallet amounts retain all fractional digits beyond floating point precision' do
    render_treasury(treasury_token, raw_units: 9_007_199_254_740_993, registry_decimals: 6)

    assert_response :success
    assert_select '.treasury-wallet-amount', text: '9007199254.740993 BEEP', count: 2
  end

  private

  def treasury_token
    ApprovedToken.create!(
      asset_unit: ('a' * 56) + '42454550', policy_id: 'a' * 56,
      ticker: 'BEEP', display_name: 'BEEP', decimals: 0
    )
  end

  def render_treasury(token, raw_units:, registry_decimals:)
    https!
    admin = Administrator.create!(email: 'wallet-display-admin@example.test', password: 'test-password-123')
    sign_in admin
    snapshot = {
      address: 'addr1testtreasury', checked_at: Time.current, stale: false, error: nil,
      lovelace_units: 21_155_080,
      assets: {
        token.asset_unit => {
          raw_units: raw_units, configured_decimals: token.decimals,
          registry_decimals: registry_decimals,
          registry_warning: registry_decimals.nil? ? 'Registry decimals unavailable' : nil,
          decimals_mismatch: !registry_decimals.nil? && token.decimals != registry_decimals
        }
      }
    }
    snapshot_service = Object.new
    snapshot_service.define_singleton_method(:call) { |tokens:| snapshot }
    TreasurySnapshotService.stub(:new, -> { snapshot_service }) { get '/admin/financials' }
  end
end