require 'test_helper'

class SportsDataSamplesControllerTest < ActionDispatch::IntegrationTest
  setup { https! }

  test 'historical fantasy data preview is retired before authentication' do
    get fantasy_data_samples_path
    assert_response :gone
  end

  test 'authenticated preview cannot be accessed and causes no writes' do
    user = User.create!(username: "sample-#{SecureRandom.hex(4)}",
      email: "sample-#{SecureRandom.hex(4)}@example.com",
      password: 'password123', password_confirmation: 'password123')
    sign_in user
    assert_no_difference ['User.count', 'Mlb::Game.count', 'Wager.count', 'Transaction.count'] do
      get fantasy_data_samples_path
    end
    assert_response :gone
    assert_equal SportsbookOnly::MESSAGE, response.body
  end
end