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
    return nil unless response

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
      type: response['type']
    }
  rescue StandardError => e
    Rails.logger.error "Blockfrost get_address_info error: #{e.message}"
    nil
  end

  def get_balance(address)
    info = get_address_info(address)
    return nil unless info
    info[:ada_balance]
  end

  def get_stake_pools(count: 10, page: 1)
    make_request("/pools?count=#{count}&page=#{page}")
  rescue StandardError => e
    Rails.logger.error "Blockfrost API Error: #{e.message}"
    nil
  end

  def get_pool_info(pool_id)
    make_request("/pools/#{pool_id}")
  rescue StandardError => e
    Rails.logger.error "Blockfrost API Error: #{e.message}"
    nil
  end

  def validate_address(address)
    return false if address.blank?
    response = make_request("/addresses/#{address}")
    response.present?
  rescue StandardError => e
    Rails.logger.error "Invalid Cardano address: #{e.message}"
    false
  end

  private

  def make_request(endpoint)
    uri = URI("#{BASE_URL}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    cert_file = ENV['SSL_CERT_FILE'] || '/etc/ssl/certs/ca-certificates.crt'
    if File.exist?(cert_file)
      http.ca_file = cert_file
    else
      nix_cert = Dir.glob('/nix/store/*-nss-cacert-*/etc/ssl/certs/ca-bundle.crt').first
      if nix_cert
        http.ca_file = nix_cert
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    request = Net::HTTP::Get.new(uri)
    request['project_id'] = @project_id

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.error "Blockfrost API Error: #{response.code} - #{response.body}"
      nil
    end
  end
end
