RSpec.configure do |config|
  config.before(:each, sportsdata: true) do

    stubxml = -> (url, filename) do
      path = Rails.root.join 'spec', 'support', 'xml', "#{filename}.xml"
      stub_request(:get, %r[#{url}]).to_return body: File.new(path)
    end

    stubjson = -> (url, filename) do
      path = Rails.root.join 'spec', 'support', 'json', "#{filename}.json"
      stub_request(:get, %r[#{url}]).to_return body: File.new(path)
    end

    stubxml.('api.sportsdatallc.org/mlb-p4/teams/(.*).xml', 'mlb/teams')
    stubxml.('api.sportsdatallc.org/mlb-p4/schedule/(.*).xml', 'mlb/schedule')
    stubxml.('api.sportsdatallc.org/mlb-p4/rosters/(.*).xml', 'mlb/roster')
    stubxml.('api.sportsdatallc.org/mlb-p4/statistics/(.*).xml', 'mlb/statistics')
    stubxml.('api.sportsdatallc.org/mlb-p4/seasontd/teams/(.*).xml', 'mlb/seasontd')
    stubxml.('api.sportsdatallc.org/mlb-p4/standings/(.*).xml', 'mlb/standings')
    stubxml.('api.sportsdatallc.org/mlb-p4/seasontd/players/(.*).xml', 'mlb/seasontd-players')
    stubxml.('api.sportsdatallc.org/mlb-p4/event/(.*).xml', 'mlb/event-info')
    stubxml.('api.sportsdatallc.org/mlb-images-p2/(.*)/headshots/(.*)', 'mlb/headshots')

    stubjson.('api.sportsdatallc.org/nfl-rt1/teams/hierarchy.json', 'nfl/teams')
    stubjson.('api.sportsdatallc.org/nfl-rt1/teams/(.*)/roster.json', 'nfl/roster')
    stubjson.('api.sportsdatallc.org/nfl-rt1/(.*)/REG/schedule.json', 'nfl/schedule')
    stubjson.('api.sportsdatallc.org/nfl-rt1/teams/(.*)/REG/standings.json', 'nfl/standings')
    stubjson.('api.sportsdatallc.org/nfl-rt1/(.*)/statistics.json', 'nfl/statistics')
    stubjson.('api.sportsdatallc.org/nfl-rt1/teams/(.*)/statistics.json', 'nfl/seasontd')
    stubxml.('api.sportsdatallc.org/nfl-images-p2/(.*)/headshots/(.*)', 'nfl/headshots')
  end

  config.before(:each) do
    stub_request(:post, %r[gcm/send]).to_return status: 200, body: '{}'
  end
end