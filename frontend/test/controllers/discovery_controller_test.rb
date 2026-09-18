require 'test_helper'

class DiscoveryControllerTest < ActionDispatch::IntegrationTest
  test 'robots is available anonymously and uses the environment policy' do
    get '/robots.txt'

    assert_response :success
    assert_equal 'text/plain', response.media_type
    assert_includes response.body, "User-agent: *\n"
    assert_includes response.body, "Disallow: /\n"
  end

  test 'sitemap contains exactly the curated public paths at the verified origin' do
    get '/sitemap.xml'

    assert_response :success
    assert_equal 'application/xml', response.media_type
    locations = response.body.scan(%r{<loc>([^<]+)</loc>}).flatten
    expected = CrawlerPolicy::PUBLIC_PATHS.map { |path| "#{CrawlerPolicy::ORIGIN}#{path}" }
    assert_equal expected, locations
    refute_includes response.body, '<lastmod>'
    CrawlerPolicy::PRIVATE_PATHS.each do |path|
      refute_includes locations, "#{CrawlerPolicy::ORIGIN}#{path}"
    end
  end

  test 'head requests are anonymous for dynamic discovery documents' do
    head '/robots.txt'
    assert_response :success

    head '/sitemap.xml'
    assert_response :success
  end

  test 'llms document follows the proposed structure and uses verified public links' do
    get '/llms.txt'

    assert_response :success
    assert_equal 'text/plain', response.media_type
    assert_match(/\A# SportsBeep\n\n>/, response.body)
    assert_includes response.body, '## Public pages'
    assert_includes response.body, '## Policies'
    assert_includes response.body, '## Optional'

    links = response.body.scan(/\]\((https:\/\/[^)]+)\)/).flatten
    assert links.present?
    assert links.all? { |url| url.start_with?("#{CrawlerPolicy::ORIGIN}/") }
    refute links.any? { |url| CrawlerPolicy.private_path?(URI.parse(url).path) }
  end
end