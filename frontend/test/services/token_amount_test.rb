require 'test_helper'

class TokenAmountTest < ActiveSupport::TestCase
  test 'parses decimals exactly into smallest units' do
    assert_equal 123_400, TokenAmount.parse('12.34', decimals: 4)
    assert_equal '12.34', TokenAmount.format(123_400, decimals: 4)
  end

  test 'does not round excess decimal places' do
    assert_raises(TokenAmount::InvalidAmount) { TokenAmount.parse('1.001', decimals: 2) }
  end

  test 'rejects scientific notation, signs, and zero' do
    %w[0 -1 1e3 +1].each do |value|
      assert_raises(TokenAmount::InvalidAmount) { TokenAmount.parse(value, decimals: 6) }
    end
  end
end