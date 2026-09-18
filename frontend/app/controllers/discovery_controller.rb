class DiscoveryController < ApplicationController
  CACHE_DURATION = 1.hour

  def robots
    cache_discovery_response
    render plain: CrawlerPolicy.robots(production: Rails.env.production?),
           content_type: 'text/plain'
  end

  def sitemap
    cache_discovery_response
    urls = CrawlerPolicy::PUBLIC_PATHS.map do |path|
      "  <url><loc>#{CrawlerPolicy::ORIGIN}#{path}</loc></url>"
    end
    document = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      #{urls.join("\n")}
      </urlset>
    XML

    render xml: document
  end

  def llms
    cache_discovery_response
    send_file Rails.root.join('public', 'llms.txt'),
              type: 'text/plain',
              disposition: 'inline'
  end

  private

  def cache_discovery_response
    expires_in CACHE_DURATION, public: true, must_revalidate: true
  end
end