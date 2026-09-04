require 'net/http'
require 'json'

class BlockfrostService
  BASE_URL = 'https://cardano-mainnet.blockfrost.io/api/v0'
  LOVELACE_PER_ADA = 1_000_000.0
  class RequestError < StandardError; end

  def initialize
    @project_id = ENV['BLOCKFROST_PROJECT_ID']
  end

  def get_address_info(address)
    if stake_address?(address)
      get_info_by_stake(address)
    else
      get_info_by_payment(address)
    end
  end

  def get_balance(address)
    info = get_address_info(address)
    info[:ada_balance]
  end

  def validate_address(address)
    return false if address.blank?
    address.start_with?('addr1') || address.start_with?('stake1')
  end

  def get_beep_balance(address)
    info = get_address_info(address)
    tokens = info[:tokens] || []
    beep_asset_unit = ENV['BEEP_ASSET_UNIT'].to_s.strip
    beep_policy_id = ENV['BEEP_POLICY_ID'].to_s.strip
    beep_qty = 0

    tokens.each do |token|
      unit = token['unit'].to_s
      qty  = token['quantity'].to_i

      if beep_asset_unit.present?
        beep_qty += qty if unit == beep_asset_unit
      elsif beep_policy_id.present?
        beep_qty += qty if unit.start_with?(beep_policy_id)
      else
        asset_name_hex = unit.length > 56 ? unit[56..] : ''
        begin
          asset_name = [asset_name_hex].pack('H*').upcase
          beep_qty += qty if asset_name.include?('BEEP')
        rescue
          beep_qty += qty if unit.downcase.include?('beep')
        end
      end
    end

    beep_qty
  rescue StandardError => e
    Rails.logger.error "Blockfrost get_beep_balance error: #{e.message}"
    0
  end

  # --- transaction inspection (for on-chain deposit verification) ---

  def get_tx(tx_hash)
    make_request("/txs/#{tx_hash}", raise_on_error: true)
  end

  def get_tx_utxos(tx_hash)
    make_request("/txs/#{tx_hash}/utxos", raise_on_error: true)
  end

  def latest_block_height
    block = make_request('/blocks/latest', raise_on_error: true)
    block ? block['height'].to_i : nil
  end

  # Confirmations for a transaction, or nil if not yet on-chain.
  def tx_confirmations(tx_hash)
    tx = get_tx(tx_hash)
    return nil if tx.nil? || tx['block_height'].blank?
    tip = latest_block_height
    return nil if tip.nil?
    tip - tx['block_height'].to_i + 1
  end

  # STRICT $BEEP asset check for on-chain money movement. Requires
  # BEEP_ASSET_UNIT (policy ID + asset name) — never falls back to policy-only
  # or name matching, which could accept another asset from the same policy.
  def beep_unit?(unit)
    expected = ENV['BEEP_ASSET_UNIT'].to_s.strip
    raise 'BEEP_ASSET_UNIT is required for on-chain transfer verification' if expected.blank?
    unit.to_s == expected
  end

  private

  def stake_address?(address)
    address.to_s.start_with?('stake1')
  end

  def get_info_by_payment(address)
    response = make_request("/addresses/#{address}")

    if response.nil?
      # Try to derive stake address and fall back to stake query
      return { ada_balance: 0.0, tokens: [], stake_address: nil, type: nil, status: 'not_found' }
    end

    ada_balance = 0.0
    tokens = []

    if response['amount'].is_a?(Array)
      response['amount'].each do |asset|
        if asset['unit'] == 'lovelace'
          ada_balance = asset['quantity'].to_f / LOVELACE_PER_ADA
        else
          tokens << asset
        end
      end
    end

    stake_addr = response['stake_address']

    # If the payment address has no tokens, supplement with stake-level asset query
    if tokens.empty? && stake_addr.present?
      stake_tokens = get_stake_assets(stake_addr)
      tokens = stake_tokens if stake_tokens.any?
    end

    # Also get ADA across all stake addresses if payment address shows 0
    if ada_balance == 0.0 && stake_addr.present?
      stake_info = make_request("/accounts/#{stake_addr}")
      if stake_info && stake_info['controlled_amount']
        ada_balance = stake_info['controlled_amount'].to_f / LOVELACE_PER_ADA
      end
    end

    {
      ada_balance: ada_balance,
      tokens: tokens,
      stake_address: stake_addr,
      type: response['type'],
      status: 'active'
    }
  rescue StandardError => e
    Rails.logger.error "Blockfrost get_address_info error: #{e.message}"
    { ada_balance: 0.0, tokens: [], stake_address: nil, type: nil, status: 'error' }
  end

  def get_info_by_stake(stake_address)
    stake_info = make_request("/accounts/#{stake_address}")

    if stake_info.nil?
      return { ada_balance: 0.0, tokens: [], stake_address: stake_address, type: nil, status: 'not_found' }
    end

    ada_balance = stake_info['controlled_amount'].to_f / LOVELACE_PER_ADA
    tokens = get_stake_assets(stake_address)

    {
      ada_balance: ada_balance,
      tokens: tokens,
      stake_address: stake_address,
      type: 'stake',
      status: 'active'
    }
  rescue StandardError => e
    Rails.logger.error "Blockfrost get_info_by_stake error: #{e.message}"
    { ada_balance: 0.0, tokens: [], stake_address: stake_address, type: nil, status: 'error' }
  end

  def get_stake_assets(stake_address)
    all_assets = []
    page = 1
    loop do
      batch = make_request("/accounts/#{stake_address}/addresses/assets?count=100&page=#{page}")
      break if batch.nil? || !batch.is_a?(Array) || batch.empty?
      all_assets.concat(batch.map { |a| { 'unit' => a['unit'], 'quantity' => a['quantity'] } })
      break if batch.size < 100
      page += 1
    end
    all_assets
  rescue StandardError => e
    Rails.logger.error "Blockfrost get_stake_assets error: #{e.message}"
    []
  end

  def make_request(endpoint, raise_on_error: false)
    uri = URI("#{BASE_URL}#{endpoint}")
    http = SecureHttp.client(uri)

    request = Net::HTTP::Get.new(uri)
    request['project_id'] = @project_id

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    elsif response.code == '404'
      nil
    else
      Rails.logger.error "Blockfrost API Error: #{response.code} - #{response.body}"
      raise RequestError, "Blockfrost returned HTTP #{response.code}" if raise_on_error
      nil
    end
  end
end
