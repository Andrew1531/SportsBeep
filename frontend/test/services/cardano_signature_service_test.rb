require 'test_helper'

class CardanoSignatureServiceTest < ActiveSupport::TestCase
  setup do
    @signing_key = Ed25519::SigningKey.generate
    @public_key = @signing_key.verify_key.to_bytes
    credential = Blake2b.bytes(@public_key, Blake2b::Key.none, 28).pack('C*')
    @address = [0x61].pack('C') + credential + ('s' * 28)
    @nonce = 'SportsBeep wallet verification test nonce'
    @protected_headers = CBOR.encode({ 1 => -8, 'address' => @address })
    signature = @signing_key.sign(
      CBOR.encode(['Signature1', @protected_headers, ''.b, @nonce])
    )
    @sign1_value = [@protected_headers, {}, @nonce, signature]
    @key_hex = CBOR.encode(
      { 1 => 1, 3 => -8, -1 => 6, -2 => @public_key }
    ).unpack1('H*')
  end

  test 'accepts a standards-compliant tag-18 CIP-8 signature' do
    result = verify(CBOR::Tagged.new(18, @sign1_value))

    assert result.valid, result.error
    assert_nil result.error
  end

  test 'rejects an untagged COSE Sign1 structure' do
    result = verify(@sign1_value)

    refute result.valid
    assert_equal 'Malformed signature tag', result.error
  end

  test 'rejects a COSE Sign1 structure with the wrong tag' do
    result = verify(CBOR::Tagged.new(17, @sign1_value))

    refute result.valid
    assert_equal 'Malformed signature tag', result.error
  end

  test 'rejects a signature whose key does not match the address' do
    other_address = [0x61].pack('C') + ('x' * 56)
    result = verify(CBOR::Tagged.new(18, @sign1_value), other_address)

    refute result.valid
    assert_equal 'Key does not match the wallet address', result.error
  end

  private

  def verify(sign1, address = @address)
    CardanoSignatureService.verify(
      signature_hex: CBOR.encode(sign1).unpack1('H*'),
      key_hex: @key_hex,
      address_bytes: address,
      expected_payload: @nonce
    )
  end
end