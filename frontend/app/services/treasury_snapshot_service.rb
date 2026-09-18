require 'json'
require 'net/http'
require 'digest'

class TreasurySnapshotService
  BASE_URL = 'https://cardano-mainnet.blockfrost.io/api/v0'.freeze
  FRESH_TTL = 5.minutes
  ERROR_TTL = 30.seconds
  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 5

  class RequestError < StandardError; end

  def initialize(cache: Rails.cache, requester: nil, project_id: ENV['BLOCKFROST_PROJECT_ID'],
                 address: ENV['TREASURY_ADDRESS'])
    @cache = cache
    @requester = requester
    @project_id = project_id.to_s.strip
    @address = address.to_s.strip
  end

  def call(tokens: ApprovedToken.order(:ticker, :id).to_a, force_refresh: false)
    token_settings = tokens.map { |token| "#{token.asset_unit.downcase}=#{token.decimals}" }
    cache_identity = Digest::SHA256.hexdigest([@address, *token_settings.sort].join(':'))
    fresh_key = "treasury_snapshot/fresh/#{cache_identity}"
    last_key = "treasury_snapshot/last_success/#{cache_identity}"
    error_key = "treasury_snapshot/error/#{cache_identity}"

    fresh = @cache.read(fresh_key)
    return fresh if fresh && !force_refresh
    recent_error = @cache.read(error_key)
    return recent_error if recent_error

    validate_configuration!
    snapshot = fetch_snapshot(tokens)
    @cache.write(fresh_key, snapshot, expires_in: FRESH_TTL)
    @cache.write(last_key, snapshot)
    snapshot
  rescue StandardError => e
    last = defined?(last_key) ? @cache.read(last_key) : nil
    failure = if last
                last.merge(stale: true, error: e.message, attempted_at: Time.current)
              else
                {
                  address: @address.presence,
                  checked_at: nil,
                  attempted_at: Time.current,
                  stale: true,
                  error: e.message,
                  lovelace_units: nil,
                  assets: {}
                }
              end
    @cache.write(error_key, failure, expires_in: ERROR_TTL) if defined?(error_key)
    failure
  end

  private

  def validate_configuration!
    raise RequestError, 'TREASURY_ADDRESS is not configured.' if @address.blank?
    raise RequestError, 'TREASURY_ADDRESS is malformed; a Cardano mainnet payment address is required.' unless @address.match?(/\Aaddr1[0-9a-z]+\z/)
    raise RequestError, 'BLOCKFROST_PROJECT_ID is not configured.' if @project_id.blank?
  end

  def fetch_snapshot(tokens)
    address_info = get_json("/addresses/#{@address}")
    raise RequestError, 'Blockfrost address response is malformed.' unless address_info.is_a?(Hash) && address_info['amount'].is_a?(Array)

    amounts = address_info['amount'].each_with_object({}) do |amount, result|
      raise RequestError, 'Blockfrost address amount list is malformed.' unless amount.is_a?(Hash) && amount['unit'].present?
      result[amount['unit'].to_s.downcase] = strict_units(amount['quantity'])
    end
    raise RequestError, 'Blockfrost address response omitted lovelace.' unless amounts.key?('lovelace')

    assets = tokens.each_with_object({}) do |token, result|
      raw_units = amounts.fetch(token.asset_unit.downcase, 0)
      metadata = get_json("/assets/#{token.asset_unit}", allow_not_found: true)
      raise RequestError, 'Blockfrost asset metadata response is malformed.' unless metadata.is_a?(Hash)

      registry_value = metadata.dig('metadata', 'decimals')
      registry_decimals = sane_decimals(registry_value)
      registry_warning = if registry_value.nil?
                           'Registry decimals unavailable'
                         elsif registry_decimals.nil?
                           'Registry decimals invalid'
                         end

      result[token.asset_unit] = {
        raw_units: raw_units,
        configured_decimals: token.decimals,
        registry_decimals: registry_decimals,
        registry_warning: registry_warning,
        decimals_mismatch: !registry_decimals.nil? && registry_decimals != token.decimals
      }
    end

    {
      address: @address,
      checked_at: Time.current,
      attempted_at: Time.current,
      stale: false,
      error: nil,
      lovelace_units: amounts.fetch('lovelace'),
      assets: assets
    }
  end

  def strict_units(value)
    text = value.to_s
    raise RequestError, 'Blockfrost returned a non-integer asset quantity.' unless text.match?(/\A\d+\z/)

    text.to_i
  end

  def sane_decimals(value)
    parsed = case value
             when Integer then value
             when String then value.to_i if value.match?(/\A\d+\z/)
             end
    parsed if parsed && parsed.between?(0, 30)
  end

  def get_json(path, allow_not_found: false)
    return @requester.call(path) if @requester

    uri = URI("#{BASE_URL}#{path}")
    http = SecureHttp.client(uri, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT)
    request = Net::HTTP::Get.new(uri)
    request['project_id'] = @project_id
    response = http.request(request)
    return {} if allow_not_found && response.code == '404'
    raise RequestError, "Blockfrost returned HTTP #{response.code}." unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue JSON::ParserError
    raise RequestError, 'Blockfrost returned an invalid response.'
  end
end