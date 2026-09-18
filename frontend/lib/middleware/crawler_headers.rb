# Wrap authentication redirects and static responses as well as controller pages.
# Crawler instructions are not an access-control mechanism.
class CrawlerHeaders
  RESTRICTED_ROBOTS = 'noindex, nofollow, noarchive, nosnippet'.freeze

  def initialize(app, production: Rails.env.production?)
    @app = app
    @production = production
  end

  def call(env)
    # Warden can rewrite PATH_INFO when forwarding to its login failure app.
    # Classify the original request, not the rewritten authentication path.
    path = env.fetch('PATH_INFO', '/').dup
    private_path = CrawlerPolicy.private_path?(path)
    status, headers, body = @app.call(env)
    headers = headers.dup

    if private_path || !@production
      headers['X-Robots-Tag'] = RESTRICTED_ROBOTS
    end

    if private_path
      headers['Cache-Control'] = 'private, no-store, max-age=0'
      headers['Pragma'] = 'no-cache'
      headers['Expires'] = '0'
    elsif CrawlerPolicy::PUBLIC_PATHS.include?(path) && status == 200
      discovery_link = '</llms.txt>; rel="describedby"; type="text/plain"'
      headers['Link'] = [headers['Link'], discovery_link].compact.join(', ')
    end

    [status, headers, body]
  end
end