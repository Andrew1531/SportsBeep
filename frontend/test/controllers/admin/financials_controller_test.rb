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
end