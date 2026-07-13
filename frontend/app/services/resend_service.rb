require 'net/http'
require 'json'

# Sends transactional email through the Replit Resend connector proxy.
# Integration: Resend connector (Replit-managed credentials — no API key in env).
# The proxy at REPLIT_CONNECTORS_HOSTNAME injects the real Resend API key;
# we authenticate with the Repl identity token (REPL_IDENTITY in the workspace,
# WEB_REPL_RENEWAL in deployments).
class ResendService
  class Error < StandardError; end

  FROM_CACHE_TTL = 300

  def self.connectors_host
    ENV['REPLIT_CONNECTORS_HOSTNAME'].presence || 'connectors.replit.com'
  end

  def self.send_email(to:, subject:, html: nil, text: nil, from: nil)
    from = from.presence || from_address
    uri = URI("https://#{connectors_host}/api/v2/proxy/emails")
    http = SecureHttp.client(uri)

    request = Net::HTTP::Post.new(
      uri,
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'X-Replit-Token' => identity_token,
      'Connector-Name' => 'resend'
    )
    payload = { from: from, to: Array(to), subject: subject }
    payload[:html] = html if html.present?
    payload[:text] = text if text.present?
    request.body = payload.to_json

    begin
      response = http.request(request)
    rescue StandardError => e
      Rails.logger.error "Resend network error: #{e.class}: #{e.message}"
      raise Error, 'Could not reach the email service.'
    end

    body = begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      {}
    end

    if response.is_a?(Net::HTTPSuccess)
      Rails.logger.info "Resend: sent email #{body['id']} (from #{from}) to #{Array(to).join(', ')}"
      body
    else
      Rails.logger.error "Resend API error: HTTP #{response.code} — #{body['message'] || response.body.to_s[0, 200]}"
      raise Error, body['message'].presence || "Resend returned HTTP #{response.code}"
    end
  end

  # From-address resolution:
  # 1. RESEND_FROM_EMAIL env var (set to e.g. support@sportsbeep.com once the
  #    sportsbeep.com domain is verified in Resend)
  # 2. from_email configured on the Replit Resend connection
  # 3. onboarding@resend.dev (Resend's always-available test sender; can only
  #    deliver to the Resend account owner's own address)
  def self.from_address
    ENV['RESEND_FROM_EMAIL'].presence || connection_from_email.presence || 'onboarding@resend.dev'
  end

  def self.connection_from_email
    if defined?(@from_email_at) && @from_email_at && (Time.now - @from_email_at) < FROM_CACHE_TTL
      return @from_email
    end

    uri = URI("https://#{connectors_host}/api/v2/connection?include_secrets=true&connector_names=resend")
    http = SecureHttp.client(uri)
    request = Net::HTTP::Get.new(uri, 'Accept' => 'application/json', 'X_REPLIT_TOKEN' => identity_token)
    response = http.request(request)
    items = JSON.parse(response.body)['items'] || []
    conn = items.find { |i| i['connector_name'] == 'resend' } || items.first
    @from_email = conn&.dig('settings', 'from_email').presence
    @from_email_at = Time.now
    @from_email
  rescue StandardError => e
    Rails.logger.warn "Resend: could not fetch connection from_email: #{e.class}: #{e.message}"
    nil
  end

  def self.identity_token
    return "repl #{ENV['REPL_IDENTITY']}" if ENV['REPL_IDENTITY'].present?
    return "depl #{ENV['WEB_REPL_RENEWAL']}" if ENV['WEB_REPL_RENEWAL'].present?

    raise Error, 'Replit identity token not found (REPL_IDENTITY / WEB_REPL_RENEWAL missing).'
  end
end
