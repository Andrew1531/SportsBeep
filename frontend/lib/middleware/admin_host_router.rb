# frozen_string_literal: true

# Keeps a dedicated administrative hostname from serving public application
# routes. This middleware is only a routing boundary; the downstream
# application remains responsible for authenticating and authorizing admins.
class AdminHostRouter
  ADMIN_ROBOTS = "User-agent: *\nDisallow: /\n".freeze
  ADMIN_ROBOTS_TAG = 'noindex, nofollow, noarchive, nosnippet'.freeze
  ADMIN_CACHE_CONTROL = 'private, no-store'.freeze

  def initialize(app, admin_host: ENV.fetch('ADMIN_HOST', ''), production: ENV['RAILS_ENV'] == 'production',
                 login_alias: true)
    @app = app
    @admin_host = normalize_configured_host(admin_host)
    @production = production
    @login_alias = login_alias
  end

  def call(env)
    # Classify the original request before any downstream middleware (including
    # Warden) gets an opportunity to alter the Rack environment.
    original_path = env.fetch('PATH_INFO', '/')
    host = request_host(env)

    return @app.call(env) unless configured?

    path = canonical_path(original_path)
    return not_found if path.nil? && (host == @admin_host || @production)
    return @app.call(env) unless path

    if host == @admin_host
      call_admin_host(env, path)
    elsif @production && administrative_path?(path)
      not_found
    else
      @app.call(env)
    end
  end

  private

  def configured?
    !@admin_host.empty?
  end

  def normalize_configured_host(host)
    value = host.to_s.strip
    return '' if value.empty?

    normalized = extract_hostname(value)
    raise ArgumentError, 'admin_host must be a bare DNS hostname, optionally followed by a numeric port' unless normalized

    normalized
  end

  def request_host(env)
    extract_hostname(env.fetch('HTTP_HOST', ''))
  end

  def canonical_path(path)
    value = path.to_s.dup

    # Decode every encoded layer so classification cannot disagree with a
    # proxy or Rails after either one normalizes PATH_INFO.
    5.times do
      break unless value.include?('%')
      return unless value.match?(/\A(?:[^%]|%[0-9a-fA-F]{2})*\z/)

      value = value.gsub(/%([0-9a-fA-F]{2})/) { Regexp.last_match(1).to_i(16).chr }
    end
    return if value.include?('%')

    value.force_encoding(Encoding::UTF_8)
    return unless value.valid_encoding?
    return if value.each_byte.any? { |byte| byte < 0x20 || byte == 0x7f }

    value = value.tr('\\', '/').gsub(%r{/+}, '/')
    return unless value.start_with?('/')
    return if value.split('/').any? { |segment| segment == '.' || segment == '..' }

    value
  end

  def extract_hostname(value)
    match = value.to_s.strip.downcase.match(/\A([^:]+?)(?::\d+)?\z/)
    return unless match

    hostname = match[1].sub(/\.\z/, '')
    return unless hostname.match?(/\A[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?\z/)

    hostname
  end

  def call_admin_host(env, path)
    if path == '/'
      return call_downstream(env.merge('PATH_INFO' => '/admin/financials'))
    end

    if path == '/robots.txt'
      return robots_response if get_or_head?(env)

      return not_found
    end

    if @login_alias && path == '/login'
      return not_found unless login_method?(env)

      return call_downstream(env.merge('PATH_INFO' => '/administrators/login'))
    end

    return call_downstream(env.merge('PATH_INFO' => path)) if permitted_admin_host_path?(path)

    not_found
  end

  def call_downstream(env)
    status, headers, body = @app.call(env)
    protected_headers = headers.dup
    protected_headers['X-Robots-Tag'] = ADMIN_ROBOTS_TAG
    protected_headers['Cache-Control'] = ADMIN_CACHE_CONTROL
    [status, protected_headers, body]
  end

  def robots_response
    [
      200,
      admin_headers.merge(
        'Content-Type' => 'text/plain; charset=utf-8',
        'Content-Length' => ADMIN_ROBOTS.bytesize.to_s
      ),
      [ADMIN_ROBOTS]
    ]
  end

  def not_found
    body = "Not Found\n"
    [
      404,
      admin_headers.merge(
        'Content-Type' => 'text/plain; charset=utf-8',
        'Content-Length' => body.bytesize.to_s
      ),
      [body]
    ]
  end

  def admin_headers
    {
      'X-Robots-Tag' => ADMIN_ROBOTS_TAG,
      'Cache-Control' => ADMIN_CACHE_CONTROL
    }
  end

  def permitted_admin_host_path?(path)
    administrative_path?(path) ||
      path == '/assets' || path.start_with?('/assets/') ||
      path == '/favicon.ico'
  end

  def administrative_path?(path)
    path_boundary?(path, '/admin') || path_boundary?(path, '/administrators')
  end

  def path_boundary?(path, prefix)
    path == prefix || path.start_with?("#{prefix}/") || path.start_with?("#{prefix}.")
  end

  def get_or_head?(env)
    %w[GET HEAD].include?(env.fetch('REQUEST_METHOD', 'GET').upcase)
  end

  def login_method?(env)
    %w[GET POST].include?(env.fetch('REQUEST_METHOD', 'GET').upcase)
  end
end