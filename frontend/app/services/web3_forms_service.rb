require 'net/http'
require 'json'

# Sends form submissions to the support inbox via the Web3Forms API.
# Web3Forms is one-way: submissions are delivered to the email address the
# access key is registered under. It cannot send email to arbitrary users.
class Web3FormsService
  ENDPOINT = URI('https://api.web3forms.com/submit')

  class Error < StandardError; end

  def self.submit(subject:, from_name:, email:, message:)
    access_key = ENV['WEB3FORMS_ACCESS_KEY'].to_s.strip
    raise Error, 'Support messaging is not configured (missing access key).' if access_key.empty?

    http = SecureHttp.client(ENDPOINT)

    request = Net::HTTP::Post.new(ENDPOINT, 'Content-Type' => 'application/json', 'Accept' => 'application/json')
    request.body = {
      access_key: access_key,
      subject: subject,
      from_name: from_name,
      email: email,
      message: message
    }.to_json

    response = http.request(request)
    body = begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      {}
    end

    return true if response.is_a?(Net::HTTPSuccess) && body['success']

    Rails.logger.error "Web3Forms error: HTTP #{response.code} — #{body['message'] || response.body.to_s[0, 200]}"
    raise Error, body['message'].presence || "Web3Forms returned HTTP #{response.code}"
  end
end
