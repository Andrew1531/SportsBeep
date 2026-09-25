require 'test_helper'

class OpticOddsMlbSnapshotTest < ActiveSupport::TestCase
  setup do
    @samples = OpticOdds::MlbSnapshot.samples.index_by { |s| s['source'] }
  end

  test 'four real samples remain three distinct fixtures with two separate odds snapshots' do
    assert_equal 4, @samples.length
    odds = @samples.values.select { |s| s['kind'] == 'odds' }
    assert_equal [2, 48], odds.map { |s| s['odds'].size }.sort
    assert_equal ['F075D920FFCA'], odds.map { |s| s['fixture_id'] }.uniq
    assert_equal 3, @samples.values.map { |s| s['fixture_id'] }.uniq.size
    assert odds.all? { |s| s['completed'] && s['status'] == 'completed' && s['players'].empty? }
    assert odds.all? { |s| s['start_date'] == '2024-08-27T22:40:00Z' }
  end

  test 'team live sample preserves score innings and provider team IDs without marking final' do
    team = @samples.fetch('tigers_astros_team')
    assert_equal 'team_results', team['kind']
    assert_equal '439A1AC1DBDB', team['fixture_id']
    assert_equal %w[BF57CF7C7E07 4F11A5896C24], %w[away home].map { |side| team.dig('teams', side, 'id') }
    assert_equal 'live', team['status']
    refute team['completed']
    assert team['historical']
    assert_equal 3, team.dig('scores', 'away', 'total')
    assert_equal 0, team.dig('scores', 'home', 'total')
    assert_equal 7, team.dig('in_play', 'period').to_i
    assert_equal 9, team.dig('team_stats', 'away', 0, 'stats', 'hits')
    assert_empty team['players']
    assert_empty team['odds']
  end

  test 'all 35 live player records retain IDs positions raw values and explicit scoring gaps' do
    sample = @samples.fetch('cubs_pirates_players')
    assert_equal 'player_results', sample['kind']
    assert_equal '24E371425A5F', sample['fixture_id']
    assert_equal 35, sample['players'].size
    assert_equal %w[5045D954DFF8 98CE61698342], sample['players'].map { |p| p['team_id'] }.uniq.sort
    assert_equal 'live', sample['status']
    refute sample['completed']
    assert sample['players'].all? { |p| p['status'] == 'live' }
    assert_equal 32, sample['players'].sum { |p| p['periods'].first['stats'].fetch('hits', 0) }
    assert_equal 23, sample['players'].sum { |p| p['periods'].first['stats'].fetch('rbi', 0) }
    batter = sample['players'].find { |p| p['name'] == 'Christian Bethancourt' }
    assert_equal '89F837F2C660', batter['id']
    assert_equal 'C', batter['position']
    assert_equal 7, batter.dig('periods', 0, 'stats', 'rbi')
    assert_equal 1, batter.dig('scoring', 'stat_ids', Mlb::Stats::SINGLES.id)
    assert_includes batter.dig('scoring', 'missing_stat_ids'), Mlb::Stats::OUTS.id
    pitcher = sample['players'].find { |p| p['name'] == 'Paul Skenes' }
    assert_equal 'SP', pitcher['position']
    assert_equal 5, pitcher.dig('periods', 0, 'stats', 'innings_pitched')
    assert_equal 5, pitcher.dig('scoring', 'stat_ids', Mlb::Stats::INNINGS_PITCHED.id)
    assert_equal 82, pitcher.dig('periods', 0, 'stats', 'pitch_count')
    assert_includes pitcher.dig('scoring', 'missing_stat_ids'), Mlb::Stats::ERA.id
    assert_includes pitcher.dig('scoring', 'missing_stat_ids'), Mlb::Stats::WINS.id
    assert_empty sample['odds']
  end

  test 'rejects malformed payloads and mixed player team fixtures instead of silently defaulting' do
    assert_raises(OpticOdds::MlbSnapshot::InvalidPayload) { OpticOdds::MlbSnapshot.parse('{bad') }
    assert_raises(OpticOdds::MlbSnapshot::InvalidPayload) { OpticOdds::MlbSnapshot.parse('{"data":[]}') }
    filename = OpticOdds::MlbSnapshot::SAMPLES.fetch('cubs_pirates_players')
    raw = JSON.parse(File.read(Rails.root.join('..', 'attached_assets', filename)))
    raw['data'][0]['results'][0]['team']['id'] = 'D4F7181B2181'
    assert_raises(OpticOdds::MlbSnapshot::InvalidPayload) { OpticOdds::MlbSnapshot.parse(raw) }
    raw['data'][0]['results'][0]['team']['id'] = '98CE61698342'
    raw['data'][0]['results'][0]['stats'][0]['stats']['unknown_future_stat'] = 19
    assert_equal 19, OpticOdds::MlbSnapshot.parse(raw).dig('players', 0, 'periods', 0, 'stats', 'unknown_future_stat')
    raw['data'][0]['results'][0]['stats'][0]['stats']['unknown_future_stat'] = 'invalid'
    assert_raises(OpticOdds::MlbSnapshot::InvalidPayload) { OpticOdds::MlbSnapshot.parse(raw) }
    odds_filename = OpticOdds::MlbSnapshot::SAMPLES.fetch('royals_guardians_odds_2')
    odds = JSON.parse(File.read(Rails.root.join('..', 'attached_assets', odds_filename)))
    odds['data'][0]['odds'][0]['id'] = 'wrong-fixture:betmgm:total_runs:under'
    assert_raises(OpticOdds::MlbSnapshot::InvalidPayload) { OpticOdds::MlbSnapshot.parse(odds) }
  end
end