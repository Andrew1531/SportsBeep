require 'test_helper'

class SportsDataSamplesControllerTest < ActionDispatch::IntegrationTest
  setup { https! }

  test 'login is required for historical data preview' do
    get fantasy_data_samples_path
    assert_redirected_to new_user_session_path
  end

  test 'authenticated preview renders all 35 players without writes' do
    user = User.create!(username: "sample-#{SecureRandom.hex(4)}",
      email: "sample-#{SecureRandom.hex(4)}@example.com",
      password: 'password123', password_confirmation: 'password123')
    sign_in user
    assert_no_difference ['User.count', 'Mlb::Game.count', 'Wager.count', 'Transaction.count'] do
      get fantasy_data_samples_path
    end
    assert_response :success
    assert_includes response.body, 'Historical MLB data preview'
    assert_includes response.body, 'Christian Bethancourt'
    assert_includes response.body, 'Paul Skenes'
    assert_equal 35, response.body.scan(/<small>\([A-F0-9]+\)<\/small>/).size
    assert_includes response.body, 'Kansas City Royals'
    assert_includes response.body, 'Detroit Tigers'
    assert_includes response.body, 'Chicago Cubs'
  end
end