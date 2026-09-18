require 'test_helper'

class CrawlerHeadersTest < ActiveSupport::TestCase
  def response_for(path, production: true, status: 200)
    app = ->(_env) { [status, { 'Content-Type' => 'text/html' }, ['test']] }
    CrawlerHeaders.new(app, production: production).call('PATH_INFO' => path)
  end

  test 'private areas are excluded from indexing and caching for every response status' do
    %w[/admin /admin.json /admin/users /administrators/login /wallet.json /api/mlb/tickets /users/1 /sportsbook/place_wager].each do |path|
      [200, 302, 401, 403, 404].each do |status|
        actual_status, headers, = response_for(path, status: status)
        assert_equal status, actual_status
        assert_includes headers.fetch('X-Robots-Tag'), 'noindex'
        assert_includes headers.fetch('Cache-Control'), 'no-store'
        assert_includes headers.fetch('Cache-Control'), 'private'
        assert_nil headers['Link']
      end
    end
  end

  test 'public production pages remain indexable and advertise the AI guide' do
    CrawlerPolicy::PUBLIC_PATHS.each do |path|
      _, headers, = response_for(path)
      assert_nil headers['X-Robots-Tag']
      assert_nil headers['Cache-Control']
      assert_includes headers.fetch('Link'), '</llms.txt>; rel="describedby"'
    end
  end

  test 'development and staging responses discourage indexing even for static content' do
    %w[/ /llms.txt /whitepaper.html /sitemap.xml].each do |path|
      _, headers, = response_for(path, production: false)
      assert_includes headers.fetch('X-Robots-Tag'), 'noindex'
    end
  end

  test 'authentication rewrites cannot remove private headers from redirects' do
    app = lambda do |env|
      env['PATH_INFO'] = '/unauthenticated'
      [302, { 'Location' => '/administrators/login' }, []]
    end
    _, headers, = CrawlerHeaders.new(app, production: true).call('PATH_INFO' => '/admin')
    assert_includes headers.fetch('X-Robots-Tag'), 'noindex'
    assert_includes headers.fetch('Cache-Control'), 'no-store'
  end
end