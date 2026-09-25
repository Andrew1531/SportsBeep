require 'test_helper'
require 'minitest/mock'

class SportsbookOnlyTest < ActionDispatch::IntegrationTest
  test 'all retired web routes return 410 before authentication or mutation' do
    paths = %w[
      /fantasy /fantasy/data-samples /fantasy/nfl /fantasy/futureMLB
      /fantasy/nfl/entries /fantasy/nfl/entries/1/questions/2/answer
      /mobile/pages/how_it_works /admin/push/new /admin/push
    ]
    Background.stub(:push, -> (*) { flunk 'Retired URL enqueued a job' }) do
      assert_no_difference ['Ticket.count', 'Contest.count', 'QuestionAnswer.count'] do
        paths.each do |path|
          %i[get post patch].each do |method|
            public_send(method, path)
            assert_response :gone, "#{method.upcase} #{path}"
            assert_equal SportsbookOnly::MESSAGE, response.body
          end
        end
      end
    end
  end

  test 'fantasy api and admin routes are retired while shared routes remain routable' do
    paths = %w[
      /api/mlb/contests /api/nfl/tickets /api/mlb/games/1/pools
      /api/nfl/tickets/1/answers /api/mlb/tickets/1/players/1/scoresheet
      /api/nfl/tickets/1/timer_states /admin/mlb/questions /admin/nfl/topics
    ]
    Background.stub(:push, -> (*) { flunk 'Retired URL enqueued a job' }) do
      assert_no_difference ['Ticket.count', 'Contest.count', 'QuestionAnswer.count'] do
        paths.each do |path|
          %i[get post patch].each do |method|
            public_send(method, path)
            assert_response :gone, "#{method.upcase} #{path}"
          end
        end
      end
    end
    %w[/sportsbook /wallet].each do |path|
      get path
      refute_equal 410, response.status, path
    end
    %w[/api/mlb/games /api/nfl/teams /api/mlb/players/1/stats
       /api/users/login].each do |path|
      refute SportsbookOnly.retired_path?(path), path
    end
  end

  test 'direct fantasy entry and ticket creation cannot bypass routing' do
    assert_no_difference ['Ticket.count', 'Contest.count', 'ContestEntryFeeTransaction.count'] do
      error = assert_raises(Nfl::FantasyEntry::EntryError) do
        Nfl::FantasyEntry.new(user: nil, attributes: {}).create!
      end
      assert_equal SportsbookOnly::MESSAGE, error.message

      assert_raises(SportsbookOnly::RetiredFeature) { Mlb::Ticket.new.save! }
      assert_raises(SportsbookOnly::RetiredFeature) { EnterContest.new(Mlb::Ticket.new).call(nil, nil) }
    end
  end

  test 'shared game activation no longer builds fantasy pools or templates' do
    game = Mlb::Game.new
    assert_no_difference ['Pool.count', 'ContestTemplate.count', 'Contest.count'] do
      BettableGame.new(game).call
    end
    assert game.bettable?
    assert game.activated
    assert_empty game.pools
  end
end