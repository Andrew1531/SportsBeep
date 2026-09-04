# Verifies CIP-8 / CIP-30 signData results (COSE_Sign1 + COSE_Key) so a user
# proves they control the Cardano wallet address they are connecting.
require 'cbor'
require 'ed25519'
require 'blake2b'

class CardanoSignatureService
  Result = Struct.new(:valid, :error, keyword_init: true)

  # signature_hex: COSE_Sign1 structure (hex) returned by wallet.signData
  # key_hex:       COSE_Key structure (hex) returned by wallet.signData
  # address_bytes: raw bytes of the address the wallet signed with
  # expected_payload: the exact nonce string the server asked the wallet to sign
  def self.verify(signature_hex:, key_hex:, address_bytes:, expected_payload:)
    tagged_sign1 = CBOR.decode([signature_hex].pack('H*'))
    cose_key   = CBOR.decode([key_hex].pack('H*'))

    unless tagged_sign1.is_a?(CBOR::Tagged) && tagged_sign1.tag == 18
      return Result.new(valid: false, error: 'Malformed signature tag')
    end
    cose_sign1 = tagged_sign1.value

    unless cose_sign1.is_a?(Array) && cose_sign1.length == 4
      return Result.new(valid: false, error: 'Malformed signature structure')
    end

    protected_bstr, _unprotected, payload, signature = cose_sign1

    # 1. Payload must be exactly the nonce we issued
    unless payload.to_s == expected_payload
      return Result.new(valid: false, error: 'Signed message does not match the verification challenge')
    end

    # 2. Extract the Ed25519 public key from the COSE_Key (OKP, x = -2)
    pubkey_bytes = cose_key.is_a?(Hash) ? cose_key[-2] : nil
    unless pubkey_bytes.is_a?(String) && pubkey_bytes.bytesize == 32
      return Result.new(valid: false, error: 'Malformed public key')
    end

    # 3. Verify the Ed25519 signature over the COSE Sig_structure
    sig_structure = CBOR.encode(['Signature1', protected_bstr, ''.b, payload])
    verify_key = Ed25519::VerifyKey.new(pubkey_bytes)
    begin
      verify_key.verify(signature, sig_structure)
    rescue Ed25519::VerifyError
      return Result.new(valid: false, error: 'Signature verification failed')
    end

    # 4. The public key must hash to the credential inside the address
    key_hash = Blake2b.bytes(pubkey_bytes, Blake2b::Key.none, 28).pack('C*')
    credential = CardanoAddress.credential_hash(address_bytes)
    unless key_hash == credential
      return Result.new(valid: false, error: 'Key does not match the wallet address')
    end

    # 5. The protected header should reference the same address (defense in depth;
    #    some wallets omit it, so only enforce when present)
    begin
      headers = CBOR.decode(protected_bstr)
      if headers.is_a?(Hash) && headers['address'].is_a?(String) && !headers['address'].empty?
        unless headers['address'] == address_bytes
          return Result.new(valid: false, error: 'Signed address mismatch')
        end
      end
    rescue StandardError
      # Unparseable protected headers -> already covered by signature check
    end

    Result.new(valid: true, error: nil)
  rescue StandardError => e
    Rails.logger.error "Cardano signature verify error: #{e.class}: #{e.message}"
    Result.new(valid: false, error: 'Could not verify wallet signature')
  end
end
