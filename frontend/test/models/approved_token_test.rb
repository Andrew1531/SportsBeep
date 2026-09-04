require 'test_helper'

class ApprovedTokenTest < ActiveSupport::TestCase
  setup do
    @policy = 'a' * 56
  end

  test 'requires a complete asset unit belonging to the exact policy' do
    assert token(asset_unit: @policy + 'zz').invalid?
    assert token(asset_unit: @policy + 'a').invalid?
    assert token(policy_id: 'b' * 56).invalid?
    assert token(asset_unit: @policy + ('c' * 66)).invalid?
    assert token.valid?
  end

  test 'does not accept another asset under the same policy' do
    approved = token
    approved.save!

    assert_raises(ActiveRecord::RecordNotFound) do
      ApprovedToken.for_unit!(@policy + '4f54484552')
    end
    assert_equal approved, ApprovedToken.for_unit!(approved.asset_unit)
  end

  test 'only looks up enabled units' do
    disabled = token(enabled: false)
    disabled.save!

    assert_raises(ActiveRecord::RecordNotFound) do
      ApprovedToken.for_unit!(disabled.asset_unit)
    end
  end

  private

  def token(attributes = {})
    ApprovedToken.new({
      policy_id: @policy,
      asset_unit: @policy + '42454550',
      display_name: 'Beep',
      ticker: "B#{SecureRandom.hex(3)}",
      decimals: 6,
      enabled: true
    }.merge(attributes))
  end
end