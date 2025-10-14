require 'net/http'
require 'json'

class BlockfrostService
  BASE_URL = 'https://cardano-mainnet.blockfrost.io/api/v0'

  def initialize
    @project_id = ENV['BLOCKFROST_PROJECT_ID']
  end

  def get_balance(address)
    response = make_request("/addresses/#{address}")
    response if response
  rescue StandardError => e
    Rails.logger.error "Blockfrost API Error: #{e.message}"
    nil
  end

  def get_stake_pools(count: 10, page: 1)
    response = make_request("/pools?count=#{count}&page=#{page}")
    response if response
  rescue StandardError => e
    Rails.logger.error "Blockfrost API Error: #{e.message}"
    nil
  end

  def get_pool_info(pool_id)
    response = make_request("/pools/#{pool_id}")
    response if response
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
    request = Net::HTTP::Get.new(uri)
    request['project_id'] = @project_id

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.error "Blockfrost API Error: #{response.code} - #{response.body}"
      nil
    end
  end
end
