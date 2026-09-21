require 'test_helper'

class NflFantasyEntryTest < ActiveSupport::TestCase
  setup do
    build_nfl_fantasy_records
  end

  test 'creates a complete original roster and atomically debits exact token units' do
    before_balance = @balance.balance_units

    ticket = create_entry

    assert ticket.persisted?
    assert_equal Nfl::FantasyEntry::PLAYER_SLOTS.sort, ticket.ticket_players.pluck(:position).sort
    assert_equal Nfl::FantasyEntry::SQUAD_SLOTS.sort, ticket.ticket_squads.pluck(:position).sort
    assert_equal @players.map(&:id).sort, ticket.player_ids.sort
    assert_equal @token.parse_amount!(@pool.entry_fee.to_s), ticket.entry_fee_units
    assert_equal before_balance - ticket.entry_fee_units, @balance.reload.balance_units
    ledger = ContestEntryFeeTransaction.find_by!(account: @user.account, approved_token: @token)
    assert_equal(-ticket.entry_fee_units, ledger.amount_units)
    assert_equal 0, ledger.amount_cents
  end

  test 'edits a pregame roster without a second fee' do
    ticket = create_entry
    balance_after_entry = @balance.reload.balance_units
    ledger_count = ContestEntryFeeTransaction.count
    replacement = Nfl::Player.create!(
      team: @home, first_name: 'New', last_name: 'Flex',
      position: 'QB', on_current_roster: true
    )
    edited = entry_attributes
    edited[:players] = edited[:players].merge(flex_player: replacement.id)

    Nfl::FantasyEntry.new(user: @user, attributes: edited).update!(ticket)

    assert_equal replacement.id, ticket.reload.ticket_players.find_by!(position: 'flex_player').player_id
    assert_equal balance_after_entry, @balance.reload.balance_units
    assert_equal ledger_count, ContestEntryFeeTransaction.count
  end

  test 'rejects a fake slot contract before creating or debiting' do
    before_balance = @balance.balance_units
    attributes = entry_attributes
    attributes[:players] = attributes[:players].except(:kicker).merge(quarterback: @players[3].id)

    error = assert_raises(Nfl::FantasyEntry::EntryError) do
      Nfl::FantasyEntry.new(user: @user, attributes: attributes).create!
    end

    assert_match(/Every player and squad slot/, error.message)
    assert_equal 0, Nfl::Ticket.count
    assert_equal before_balance, @balance.reload.balance_units
  end

  private

  def create_entry
    Nfl::FantasyEntry.new(user: @user, attributes: entry_attributes).create!
  end

  def entry_attributes
    {
      game_id: @game.id, contest_id: @contest.id, approved_token_id: @token.id,
      players: Nfl::FantasyEntry::PLAYER_SLOTS.zip(@players.map(&:id)).to_h,
      squads: {
        quarterbacks: @home.id, defense: @away.id, special_teams: @home.id
      },
      league_pick_game_id: @league_game.id, league_pick_team_id: @league_home.id
    }
  end

  def build_nfl_fantasy_records
    @user = User.create!(
      username: "nfl-#{SecureRandom.hex(4)}", email: "#{SecureRandom.hex(4)}@example.com",
      password: 'password123', password_confirmation: 'password123'
    )
    policy = SecureRandom.hex(28)
    @token = ApprovedToken.create!(
      policy_id: policy, asset_unit: policy + '42454550', display_name: 'Test Beep',
      ticker: "TB#{SecureRandom.hex(2)}", decimals: 2, enabled: true
    )
    @balance = @user.account.token_balance_for(@token)
    @balance.update!(balance_units: 50_000)
    @home = create_team('Home', 'H')
    @away = create_team('Away', 'A')
    @pool = Pool.create!(prize_pool: 100, max_tickets_per_contest: 10, entry_fee_multiplier: 1)
    @game = Nfl::Game.create!(
      home_team: @home, away_team: @away, start_time: 2.days.from_now,
      status: '', bettable: false
    )
    @game.pools << @pool
    @game.update!(bettable: true)
    @players = %w[RB TE WR K QB].each_with_index.map do |position, index|
      Nfl::Player.create!(
        team: index.even? ? @home : @away, first_name: "P#{index}",
        last_name: position, position: position, on_current_roster: true
      )
    end
    build_league_pick
    questions = build_questions
    @template = ContestTemplate.new(game: @game, pool: @pool, skip_question_validation: true)
    @template.save!
    @template.questions << questions
    @template.skip_question_validation = false
    @template.save!
    @contest = Nfl::Contest.create!(template: @template)
  end

  def build_league_pick
    @league_home = create_team('League Home', 'LH')
    league_away = create_team('League Away', 'LA')
    @league_game = Nfl::Game.create!(
      home_team: @league_home, away_team: league_away,
      start_time: 3.days.from_now, status: '', bettable: false
    )
    GameLeaguePick.create!(game: @game, league_pick: @league_game)
  end

  def build_questions
    stats = [
      Nfl::Stats::TURNOVERS, Nfl::Stats::PENALTIES, Nfl::Stats::RED_ZONE_PCT,
      Nfl::Stats::THIRD_DOWN_CV, Nfl::Stats::FOURTH_DOWN_CV, Nfl::Stats::TOTAL_YDS
    ]
    stats.each_with_index.map do |stat, index|
      topic = Nfl::StatTopic.create!(stat: stat.id, comparison: 'more')
      (index < 3 ? BestQuestion : BustQuestion).create!(
        topic: topic, text: "Question #{index + 1}"
      )
    end
  end

  def create_team(name, prefix)
    Nfl::Team.create!(
      name: name, abbr: "#{prefix}#{SecureRandom.hex(1)}",
      external_id: SecureRandom.hex(6)
    )
  end
end