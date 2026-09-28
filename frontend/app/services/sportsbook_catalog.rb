require 'json'

# Local, display-only catalog. Entries never create fixtures or betting markets.
class SportsbookCatalog
  LEAGUES = {
    'mlb' => 'MLB', 'nfl' => 'NFL', 'nba' => 'NBA', 'nhl' => 'NHL',
    'mma' => 'MMA', 'ncaaf' => 'NCAA Football',
    'ncaab' => "NCAA Men's Basketball", 'mls' => 'MLS',
    'epl' => 'English Premier League'
  }.freeze
  NEW_LEAGUES = %w[mma ncaaf ncaab mls epl].freeze
  CATALOG_PATH = Rails.root.join('public', 'sports-catalog', 'catalog.json')

  def self.local_logo(path)
    return nil unless path.is_a?(String)
    return nil unless path.match?(%r{\A/sports-catalog/[a-zA-Z0-9_./-]+\.(?:png|jpg|jpeg|webp|svg)\z})
    return nil if path.split('/').include?('..')

    path
  end

  def initialize
    data = JSON.parse(File.read(CATALOG_PATH))
    @leagues = {}
    Array(data['leagues']).each do |entry|
      next unless entry.is_a?(Hash) && LEAGUES.key?(entry['key'])

      key = entry['key']
      teams = Array(entry['teams']).filter_map do |team|
        next unless team.is_a?(Hash) && team['name'].is_a?(String) && team['name'].present?

        { id: team['id'].to_s, name: team['name'], abbreviation: team['abbreviation'].to_s,
          logo: self.class.local_logo(team['logo']) }
      end
      promotion = entry['promotion']
      promotion = if key == 'mma' && promotion.is_a?(Hash) && promotion['name'].is_a?(String) && promotion['name'].present?
                    { id: promotion['id'].to_s, name: promotion['name'],
                      abbreviation: promotion['abbreviation'].to_s,
                      logo: self.class.local_logo(promotion['logo']) }
                  end
      @leagues[key] = { key: key, name: LEAGUES.fetch(key),
                        logo: self.class.local_logo(entry['logo']), teams: teams,
                        promotion: promotion }
    end
  rescue Errno::ENOENT, JSON::ParserError, TypeError => e
    Rails.logger.error "Sportsbook catalog unavailable: #{e.message}"
    @leagues = {}
  end

  def league(key)
    @leagues[key] || { key: key, name: LEAGUES.fetch(key), logo: nil, teams: [], promotion: nil }
  end

  # Exact name or ID only: never split a name into a presumed city/mascot.
  def team(key, name_or_id)
    league(key)[:teams].find { |item| item[:name] == name_or_id.to_s || item[:id] == name_or_id.to_s }
  end
end