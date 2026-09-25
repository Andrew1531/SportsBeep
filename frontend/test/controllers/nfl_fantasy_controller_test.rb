require 'test_helper'

class NflFantasyControllerTest < ActionDispatch::IntegrationTest
  test 'NFL fantasy pages and entry mutations are gone without changing history' do
    assert_no_difference ['Ticket.count', 'QuestionAnswer.count', 'Nfl::QuestionAttempt.count'] do
      get '/fantasy/nfl'
      assert_response :gone
      get '/fantasy/nfl/games/1'
      assert_response :gone
      get '/fantasy/nfl/entries/1'
      assert_response :gone
      post '/fantasy/nfl/entries', params: { game_id: 1 }
      assert_response :gone
      patch '/fantasy/nfl/entries/1', params: { game_id: 1 }
      assert_response :gone
      post '/fantasy/nfl/entries/1/questions/1/start'
      assert_response :gone
      post '/fantasy/nfl/entries/1/questions/1/answer'
      assert_response :gone
    end
  end
end