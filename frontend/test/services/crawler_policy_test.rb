require 'test_helper'

class CrawlerPolicyTest < ActiveSupport::TestCase
  test 'recognizes private paths only at path boundaries' do
    assert CrawlerPolicy.private_path?('/admin')
    assert CrawlerPolicy.private_path?('/admin/users')
    assert CrawlerPolicy.private_path?('/api/games?week=1')
    assert CrawlerPolicy.private_path?('/sportsbook/place_wager')

    refute CrawlerPolicy.private_path?('/')
    refute CrawlerPolicy.private_path?('/sportsbook')
    refute CrawlerPolicy.private_path?('/administrator')
    refute CrawlerPolicy.private_path?('/apiary')
  end

  test 'production robots permits public crawling and blocks every private prefix' do
    robots = CrawlerPolicy.robots(production: true)

    assert_includes robots, "User-agent: *\n"
    assert_includes robots, "Allow: /\n"
    assert_includes robots, "Allow: /assets/\n"
    CrawlerPolicy::PRIVATE_PATHS.each do |path|
      assert_includes robots, "Disallow: #{path}\n"
    end
    assert_includes robots, "Sitemap: #{CrawlerPolicy::ORIGIN}/sitemap.xml\n"
    refute_includes robots, 'Crawl-delay'
    refute_includes robots, 'Noindex'
  end

  test 'non-production robots blocks all crawling without production rules' do
    robots = CrawlerPolicy.robots(production: false)

    assert_includes robots, 'Preview and non-production environment'
    assert_includes robots, "User-agent: *\nDisallow: /\n"
    refute_includes robots, 'Sitemap:'
    refute_includes robots, 'Allow:'
  end
end