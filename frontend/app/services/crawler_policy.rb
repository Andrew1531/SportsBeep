class CrawlerPolicy
  ORIGIN = 'https://sports-beep.replit.app'.freeze

  PUBLIC_PATHS = [
    '/',
    '/how-to-play',
    '/tos',
    '/privacy_policy',
    '/refund_policy',
    '/sportsbook',
    '/whitepaper.html'
  ].freeze

  PRIVATE_PATHS = [
    '/admin',
    '/administrators',
    '/users',
    '/api',
    '/dashboard',
    '/play',
    '/games',
    '/fantasy',
    '/wallet',
    '/vending',
    '/transactions',
    '/redeem',
    '/profile',
    '/my-bets',
    '/reset-password',
    '/mobile',
    '/sportsbook/place_wager',
    '/cpanel',
    '/sidekiq',
    '/api-docs'
  ].freeze

  class << self
    def private_path?(path)
      normalized_path = path.to_s.split(/[?#]/, 2).first.to_s

      PRIVATE_PATHS.any? do |private_path|
        normalized_path == private_path ||
          normalized_path.start_with?("#{private_path}/", "#{private_path}.")
      end
    end

    def robots(production:)
      unless production
        return <<~ROBOTS
          # Preview and non-production environment: crawling is disabled.
          User-agent: *
          Disallow: /
        ROBOTS
      end

      rules = [
        '# Public discovery policy for SportsBeep.',
        "# AI-oriented site summary: #{ORIGIN}/llms.txt",
        'User-agent: *',
        'Allow: /',
        'Allow: /assets/',
        'Allow: /packs/'
      ]
      rules.concat(PRIVATE_PATHS.map { |path| "Disallow: #{path}" })
      rules << "Sitemap: #{ORIGIN}/sitemap.xml"
      "#{rules.join("\n")}\n"
    end
  end
end