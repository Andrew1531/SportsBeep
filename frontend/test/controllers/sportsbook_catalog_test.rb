require 'test_helper'
require 'minitest/mock'

class SportsbookCatalogTest < ActionDispatch::IntegrationTest
  CATALOG = {
    leagues: [
      { key: 'mma', name: 'MMA', logo: nil, teams: [],
        promotion: { id: '3321', name: 'Ultimate Fighting Championship',
                     abbreviation: 'UFC', logo: '/sports-catalog/mma/ufc.png' } },
      { key: 'ncaaf', name: 'NCAA Football', teams: [{ id: 'psu', name: 'Penn State Nittany Lions', logo: nil }] },
      { key: 'ncaab', name: "NCAA Men's Basketball", teams: [{ id: 'unc', name: 'North Carolina Tar Heels', logo: nil }] },
      { key: 'mls', name: 'MLS', teams: [{ id: 'lafc', name: 'Los Angeles Football Club', logo: '/sports-catalog/lafc.png' }] },
      { key: 'epl', name: 'English Premier League',
        teams: [{ id: 'man-city', name: 'Manchester City', logo: '/sports-catalog/man-city.png' }] },
      { key: 'bundesliga', name: 'Bundesliga (Germany)',
        teams: [{ id: 'bayern', name: 'Bayern Munich', logo: '/sports-catalog/bayern.png' }] }
    ]
  }.to_json.freeze

  test 'catalog uses exact names and IDs and rejects unsafe logo paths' do
    with_catalog do
      catalog = SportsbookCatalog.new
      assert_equal 'Los Angeles Football Club', catalog.team('mls', 'lafc')[:name]
      assert_equal 'lafc', catalog.team('mls', 'Los Angeles Football Club')[:id]
      assert_nil catalog.team('mls', 'Los Angeles')
      assert_nil catalog.team('mma', '3321')
      assert_equal 'Ultimate Fighting Championship', catalog.league('mma')[:promotion][:name]
      assert_nil SportsbookCatalog.local_logo('/sports-catalog/../../etc/passwd.png')
      assert_nil SportsbookCatalog.local_logo('https://example.com/logo.png')
    end
  end

  test 'each new league is a browsable directory, not a synthetic betting market' do
    with_catalog do
      {
        'mma' => ['MMA', 'Ultimate Fighting Championship', 'UFC'],
        'ncaaf' => ['NCAA Football', 'Penn State Nittany Lions'],
        'ncaab' => ["NCAA Men's Basketball", 'North Carolina Tar Heels'],
        'mls' => ['MLS', 'Los Angeles Football Club'],
        'epl' => ['English Premier League', 'Manchester City'],
        'bundesliga' => ['Bundesliga (Germany)', 'Bayern Munich']
      }.each do |key, names|
        get sportsbook_path(sport: key)
        assert_response :success
        names.each { |name| assert_includes CGI.unescapeHTML(response.body), name }
        assert_includes response.body, 'No betting lines available'
        refute_includes response.body, 'dk-game-row'
        assert_empty SportsbookController.new.send(:fetch_games_with_odds, key)
      end
      assert_includes response.body, '/sports-catalog/bayern.png'
      get sportsbook_path(sport: 'mma')
      assert_select 'img[alt="Ultimate Fighting Championship logo"][src="/sports-catalog/mma/ufc.png"]'
      assert_select 'h3', text: 'Promotion'
      assert_select 'h3', text: 'Teams', count: 0
    end
  end

  test 'direct posts cannot place wagers in unsupported new leagues' do
    https!
    user = User.create!(email: 'catalog-wager@example.com', username: 'catalog-wager',
                        password: 'password123', password_confirmation: 'password123')
    SportsbookCatalog::NEW_LEAGUES.each do |key|
      sign_in user
      assert_no_difference 'Wager.count' do
        post place_wager_path, params: { wager: { sport: key, bet_type: 'moneyline', selection: 'Unverified' } }
      end
      assert_redirected_to sportsbook_path(sport: key)
      assert_equal 'Betting lines are not available for this league yet.', flash[:alert]
    end
  end

  test 'unrecognized keys cannot select an arbitrary sport' do
    with_catalog do
      get sportsbook_path(sport: 'soccer')
      assert_response :success
      assert_select '.dk-sport-tab.active', text: 'MLB'
    end
  end

  private

  def with_catalog
    original_read = File.method(:read)
    File.stub(:read, ->(path, *args, **kwargs) {
      path.to_s == SportsbookCatalog::CATALOG_PATH.to_s ? CATALOG : original_read.call(path, *args, **kwargs)
    }) { yield }
  end
end