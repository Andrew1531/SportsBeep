require 'test_helper'

class TreasurySnapshotServiceTest < ActiveSupport::TestCase
  setup do
    policy = 'c' * 56
    @token = ApprovedToken.create!(policy_id: policy, asset_unit: policy + '42454550', display_name: 'BEEP', ticker: 'BEEPT', decimals: 0)
    @cache = ActiveSupport::Cache::MemoryStore.new
  end

  test 'reports exact raw units and registry decimal mismatch without repeated requests' do
    huge = '900719925474099312345'
    calls = []
    requester = lambda do |path|
      calls << path
      if path.start_with?('/addresses/')
        { 'amount' => [{ 'unit' => 'lovelace', 'quantity' => '1234567' }, { 'unit' => @token.asset_unit, 'quantity' => huge }] }
      else
        { 'asset' => @token.asset_unit, 'metadata' => { 'decimals' => 6 } }
      end
    end
    service = TreasurySnapshotService.new(cache: @cache, requester: requester, project_id: 'project', address: 'addr1treasury')

    first = service.call(tokens: [@token])
    second = service.call(tokens: [@token])

    asset = first[:assets][@token.asset_unit]
    assert_equal huge.to_i, asset[:raw_units]
    assert_equal 0, asset[:configured_decimals]
    assert_equal 6, asset[:registry_decimals]
    assert asset[:decimals_mismatch]
    assert_equal first, second
    assert_equal 2, calls.length
  end

  test 'force refresh bypasses a successful cached snapshot' do
    calls = 0
    requester = lambda do |path|
      calls += 1
      path.start_with?('/addresses/') ?
        { 'amount' => [{ 'unit' => 'lovelace', 'quantity' => calls.to_s }] } :
        { 'metadata' => { 'decimals' => 0 } }
    end
    service = TreasurySnapshotService.new(
      cache: @cache, requester: requester, project_id: 'project', address: 'addr1treasury'
    )

    first = service.call(tokens: [@token])
    second = service.call(tokens: [@token], force_refresh: true)

    assert_operator second[:lovelace_units], :>, first[:lovelace_units]
    assert_equal 4, calls
  end

  test 'returns an explicit missing credential error without a network request' do
    called = false
    service = TreasurySnapshotService.new(
      cache: @cache,
      requester: ->(_path) { called = true },
      project_id: '',
      address: 'addr1treasury'
    )

    snapshot = service.call(tokens: [@token])

    assert snapshot[:stale]
    assert_nil snapshot[:checked_at]
    assert_match(/BLOCKFROST_PROJECT_ID/, snapshot[:error])
    refute called
  end

  test 'preserves the last successful values and marks them stale after an error' do
    failing = false
    requester = lambda do |path|
      raise 'network timeout' if failing
      path.start_with?('/addresses/') ? { 'amount' => [{ 'unit' => 'lovelace', 'quantity' => '42' }] } : { 'metadata' => nil }
    end
    service = TreasurySnapshotService.new(cache: @cache, requester: requester, project_id: 'project', address: 'addr1treasury')
    successful = service.call(tokens: [@token])
    identity = Digest::SHA256.hexdigest(['addr1treasury', "#{@token.asset_unit}=#{@token.decimals}"].join(':'))
    @cache.delete("treasury_snapshot/fresh/#{identity}")
    failing = true

    stale = service.call(tokens: [@token])

    assert stale[:stale]
    assert_equal successful[:checked_at], stale[:checked_at]
    assert_equal 42, stale[:lovelace_units]
    assert_match(/network timeout/, stale[:error])
  end
end