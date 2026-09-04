require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    https!
    @user = User.create!(
      email: 'wallet-test@example.com',
      username: 'wallet-test',
      password: 'password123',
      password_confirmation: 'password123'
    )
    sign_in @user
  end

  test 'issues and stores a signing challenge' do
    post cardano_nonce_path, as: :json

    assert_response :success
    assert JSON.parse(response.body).fetch('nonce').present?
  end

  test 'persists a wallet only after a valid tagged CIP-8 signature' do
    post cardano_nonce_path, as: :json
    nonce = JSON.parse(response.body).fetch('nonce')
    signing_key = Ed25519::SigningKey.generate
    public_key = signing_key.verify_key.to_bytes
    credential = Blake2b.bytes(public_key, Blake2b::Key.none, 28).pack('C*')
    address = [0x61].pack('C') + credential + ('s' * 28)
    protected_headers = CBOR.encode({ 1 => -8, 'address' => address })
    signature = signing_key.sign(
      CBOR.encode(['Signature1', protected_headers, ''.b, nonce])
    )
    sign1 = CBOR::Tagged.new(
      18,
      [protected_headers, {}, nonce, signature]
    )
    cose_key = { 1 => 1, 3 => -8, -1 => 6, -2 => public_key }

    post connect_cardano_path, params: {
      wallet_name: 'nami',
      address_hex: address.unpack1('H*'),
      signed_address_hex: address.unpack1('H*'),
      signature: CBOR.encode(sign1).unpack1('H*'),
      key: CBOR.encode(cose_key).unpack1('H*')
    }, as: :json

    assert_response :success
    assert JSON.parse(response.body).fetch('ok')
    @user.reload
    assert @user.cardano_wallet_address.start_with?('addr1')
    assert_equal 'nami', @user.cardano_wallet_name
    assert @user.cardano_wallet_verified_at.present?
  end

  test 'does not persist malformed signature data' do
    post cardano_nonce_path, as: :json

    post connect_cardano_path, params: {
      wallet_name: 'nami',
      address_hex: '61' + ('00' * 56),
      signed_address_hex: '61' + ('00' * 56),
      signature: CBOR.encode([1, 2, 3, 4]).unpack1('H*'),
      key: CBOR.encode({ -2 => 'x' * 32 }).unpack1('H*')
    }, as: :json

    assert_response :unprocessable_entity
    assert_nil @user.reload.cardano_wallet_verified_at
  end
end