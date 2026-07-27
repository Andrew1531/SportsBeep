# Utilities for Cardano addresses: hex (CIP-30) <-> bech32 (addr1/stake1),
# plus key-hash extraction for ownership verification.
require 'bech32'

module CardanoAddress
  module_function

  # Convert raw address bytes (from CIP-30 hex) to bech32 (addr1.../stake1...).
  def bytes_to_bech32(bytes)
    header = bytes.bytes.first
    addr_type = (header >> 4) & 0x0f
    network   = header & 0x0f
    hrp =
      if addr_type == 14 || addr_type == 15 # reward (stake) addresses
        network == 1 ? 'stake' : 'stake_test'
      else
        network == 1 ? 'addr' : 'addr_test'
      end
    data = convert_bits(bytes.bytes, 8, 5, true)
    Bech32.encode(hrp, data, Bech32::Encoding::BECH32)
  end

  def hex_to_bech32(hex)
    bytes_to_bech32([hex].pack('H*'))
  end

  # Decode a bech32 address (addr1.../stake1...) back to raw bytes.
  def bech32_to_bytes(bech32_str)
    _hrp, data, _spec = Bech32.decode(bech32_str, 120)
    return nil if data.nil?
    convert_bits(data, 5, 8, false).pack('C*')
  end

  # True when two bech32 addresses share the same stake credential (i.e. they
  # belong to the same wallet account).
  def same_wallet?(addr_a, addr_b)
    a = bech32_to_bytes(addr_a)
    b = bech32_to_bytes(addr_b)
    return false if a.nil? || b.nil?
    cred_a = reward_address?(a) ? credential_hash(a) : stake_credential_hash(a)
    cred_b = reward_address?(b) ? credential_hash(b) : stake_credential_hash(b)
    (cred_a.present? && cred_a == cred_b) || a == b
  end

  # The 28-byte credential hash embedded in the address:
  # - base/enterprise addresses: payment key hash (bytes 1..28)
  # - reward addresses: stake key hash (bytes 1..28)
  def credential_hash(bytes)
    bytes.byteslice(1, 28)
  end

  # For a base address, the stake credential occupies bytes 29..56.
  def stake_credential_hash(bytes)
    return nil unless bytes.bytesize >= 57
    bytes.byteslice(29, 28)
  end

  def mainnet?(bytes)
    (bytes.bytes.first & 0x0f) == 1
  end

  def reward_address?(bytes)
    addr_type = (bytes.bytes.first >> 4) & 0x0f
    addr_type == 14 || addr_type == 15
  end

  def convert_bits(data, from_bits, to_bits, pad)
    acc = 0
    bits = 0
    ret = []
    maxv = (1 << to_bits) - 1
    data.each do |value|
      acc = (acc << from_bits) | value
      bits += from_bits
      while bits >= to_bits
        bits -= to_bits
        ret << ((acc >> bits) & maxv)
      end
    end
    ret << ((acc << (to_bits - bits)) & maxv) if pad && bits.positive?
    ret
  end
end
