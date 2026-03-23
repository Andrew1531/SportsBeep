require 'net/http'
require 'json'

class BlockfrostService
  BASE_URL = 'https://cardano-mainnet.blockfrost.io/api/v0'
  LOVELACE_PER_ADA = 1_000_000.0

  def initialize
    @project_id = ENV['BLOCKFROST_PROJECT_ID']
  end

  def get_address_info(address)
    response = make_request("/addresses/#{address}")

    if response.nil?
      return { ada_balance: 0.0, tokens: [], stake_address: nil, type: 'byron', status: 'empty' }
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

    {
      ada_balance: ada_balance,
      tokens: tokens,
      stake_address: response['stake_address'],
      type: response['type'],
      status: 'active'
    }
  rescue StandardError => e
    Rails.logger.error "Blockfrost get_address_info error: #{e.message}"
    { ada_balance: 0.0, tokens: [], stake_address: nil, type: nil, status: 'error' }
  end

  def get_balance(address)
    info = get_address_info(address)
    info[:ada_balance]
  end

  def validate_address(address)
    return false if address.blank?
    address.start_with?('addr1')
  end

  def get_beep_balance(address)
    info = get_address_info(address)
    tokens = info[:tokens] || []
    beep_policy_id = ENV['BEEP_POLICY_ID'].to_s.strip
    beep_qty = 0

    tokens.each do |token|
      unit = token['unit'].to_s
      qty = token['quantity'].to_i

      if beep_policy_id.present?
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

  private

  def make_request(endpoint)
    uri = URI("#{BASE_URL}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri)
    request['project_id'] = @project_id

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    elsif response.code == '404'
      nil
    else
      Rails.logger.error "Blockfrost API Error: #{response.code} - #{response.body}"
      nil
    end
  end
end
