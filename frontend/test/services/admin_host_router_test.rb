# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/middleware/admin_host_router'

class AdminHostRouterTest < Minitest::Test
  ADMIN_HOST = 'admin.sportsbeep.com'

  def setup
    @calls = []
    calls = @calls
    @downstream = lambda do |env|
      calls << env.dup
      [
        200,
        { 'Content-Type' => 'text/plain', 'Cache-Control' => 'public', 'X-Robots-Tag' => 'index' },
        [env.fetch('PATH_INFO')]
      ]
    end
  end

  def test_production_refuses_admin_paths_on_normal_host
    router = build_router(production: true)

    %w[/admin /admin/ /admin.json /admin/users /administrators /administrators/ /administrators.json].each do |path|
      status, headers, = router.call(request(path, host: 'sportsbeep.com'))

      assert_equal 404, status, path
      assert_equal 'private, no-store', headers['Cache-Control'], path
      assert_equal AdminHostRouter::ADMIN_ROBOTS_TAG, headers['X-Robots-Tag'], path
    end
    assert_empty @calls
  end

  def test_dedicated_root_maps_to_financial_board_and_protects_headers
    status, headers, body = build_router.call(request('/', host: ADMIN_HOST))

    assert_equal 200, status
    assert_equal ['/admin/financials'], body
    assert_equal '/admin/financials', @calls.last['PATH_INFO']
    assert_equal 'private, no-store', headers['Cache-Control']
    assert_equal AdminHostRouter::ADMIN_ROBOTS_TAG, headers['X-Robots-Tag']
  end

  def test_login_alias_maps_get_and_post_only
    router = build_router

    %w[GET POST].each do |method|
      status, = router.call(request('/login', host: ADMIN_HOST, method: method))
      assert_equal 200, status
      assert_equal '/administrators/login', @calls.last['PATH_INFO']
    end

    status, = router.call(request('/login', host: ADMIN_HOST, method: 'PUT'))
    assert_equal 404, status
  end

  def test_login_alias_can_be_disabled
    status, = build_router(login_alias: false).call(request('/login', host: ADMIN_HOST))

    assert_equal 404, status
    assert_empty @calls
  end

  def test_dedicated_robots_disallows_everything_without_calling_app
    status, headers, body = build_router.call(request('/robots.txt', host: ADMIN_HOST))

    assert_equal 200, status
    assert_equal "User-agent: *\nDisallow: /\n", body.join
    assert_equal 'private, no-store', headers['Cache-Control']
    assert_equal AdminHostRouter::ADMIN_ROBOTS_TAG, headers['X-Robots-Tag']
    assert_empty @calls
  end

  def test_dedicated_host_permits_static_and_administrative_paths
    router = build_router

    %w[/assets/application.css /favicon.ico /admin /admin.json /administrators/login].each do |path|
      status, = router.call(request(path, host: ADMIN_HOST))
      assert_equal 200, status, path
      assert_equal path, @calls.last['PATH_INFO']
    end
  end

  def test_dedicated_host_blocks_public_discovery_and_api_paths
    router = build_router

    %w[/sportsbook /api/games /llms.txt /sitemap.xml /users/sign_in].each do |path|
      status, headers, = router.call(request(path, host: ADMIN_HOST))
      assert_equal 404, status, path
      assert_equal 'private, no-store', headers['Cache-Control'], path
    end
    assert_empty @calls
  end

  def test_development_keeps_ordinary_preview_admin_usable
    status, = build_router(production: false).call(request('/admin', host: 'preview.example.test'))

    assert_equal 200, status
    assert_equal '/admin', @calls.last['PATH_INFO']
  end

  def test_dedicated_host_is_limited_in_development
    status, = build_router(production: false).call(request('/sportsbook', host: ADMIN_HOST))

    assert_equal 404, status
    assert_empty @calls
  end

  def test_configured_host_matches_lowercase_exactly_and_ignores_request_port
    status, = build_router.call(request('/', host: 'ADMIN.SPORTSBEEP.COM:443'))

    assert_equal 200, status
    assert_equal '/admin/financials', @calls.last['PATH_INFO']
  end

  def test_format_boundary_is_private_but_similar_prefix_is_not
    router = build_router(production: true)

    assert_equal 404, router.call(request('/admin.csv', host: 'sportsbeep.com')).first
    assert_equal 404, router.call(request('/administrators/login.json', host: 'sportsbeep.com')).first
    assert_equal 200, router.call(request('/administer', host: 'sportsbeep.com')).first
    assert_equal 200, router.call(request('/administrator', host: 'sportsbeep.com')).first
  end

  def test_encoded_and_repeated_slash_admin_variants_are_private_on_normal_host
    router = build_router(production: true)

    %w[
      //admin
      ///administrators/login
      /%61dmin
      /%61dmin.json
      /admin%2Fusers
      /administrators%2flogin
      /%2561dmin
    ].each do |path|
      status, headers, = router.call(request(path, host: 'sportsbeep.com'))
      assert_equal 404, status, path
      assert_equal 'private, no-store', headers['Cache-Control'], path
    end

    assert_empty @calls
  end

  def test_dedicated_host_classifies_and_forwards_the_same_canonical_path
    status, = build_router.call(request('//%61dmin%2Ffinancials', host: ADMIN_HOST))

    assert_equal 200, status
    assert_equal '/admin/financials', @calls.last['PATH_INFO']
  end

  def test_malformed_or_excessively_encoded_paths_return_404_instead_of_raising
    router = build_router(production: true)

    ['/admin%', '/admin%2', '/admin%GG', '/admin%00users', '/%252525252561dmin'].each do |path|
      status, headers, = router.call(request(path, host: ADMIN_HOST))
      assert_equal 404, status, path
      assert_equal AdminHostRouter::ADMIN_ROBOTS_TAG, headers['X-Robots-Tag'], path
    end

    assert_empty @calls
  end

  def test_malicious_similar_host_does_not_match
    router = build_router(production: true)

    assert_equal 404, router.call(request('/admin', host: "#{ADMIN_HOST}.evil.test")).first
    assert_equal 404, router.call(request('/admin', host: "#{ADMIN_HOST}:443.evil")).first
    assert_equal 200, router.call(request('/', host: "#{ADMIN_HOST}.evil.test")).first
    assert_equal '/', @calls.last['PATH_INFO']
  end

  def test_x_forwarded_host_cannot_select_the_dedicated_host
    env = request('/admin', host: 'sportsbeep.com').merge('HTTP_X_FORWARDED_HOST' => ADMIN_HOST)

    status, = build_router(production: true).call(env)

    assert_equal 404, status
    assert_empty @calls
  end

  def test_invalid_configured_hostname_is_rejected
    error = assert_raises(ArgumentError) do
      AdminHostRouter.new(@downstream, admin_host: 'https://admin.sportsbeep.com/path', production: true)
    end

    assert_match(/bare DNS hostname/, error.message)
  end

  def test_empty_configuration_preserves_legacy_behavior
    router = AdminHostRouter.new(@downstream, admin_host: '', production: true)

    assert_equal 200, router.call(request('/admin', host: 'sportsbeep.com')).first
  end

  private

  def build_router(production: true, login_alias: true)
    AdminHostRouter.new(
      @downstream,
      admin_host: ADMIN_HOST,
      production: production,
      login_alias: login_alias
    )
  end

  def request(path, host:, method: 'GET')
    {
      'PATH_INFO' => path,
      'HTTP_HOST' => host,
      'REQUEST_METHOD' => method
    }
  end
end