require 'test_helper'
require_relative '../services/nfl_fantasy_entry_test'

class NflFantasyControllerTest < ActionDispatch::IntegrationTest
  setup do
    https!
    helper = NflFantasyEntryTest.new('temporary')
    helper.send(:build_nfl_fantasy_records)
    @user = helper.instance_variable_get(:@user)
    @game = helper.instance_variable_get(:@game)
    @contest = helper.instance_variable_get(:@contest)
    @players = helper.instance_variable_get(:@players)
    @token = helper.instance_variable_get(:@token)
    @league_game = helper.instance_variable_get(:@league_game)
    @league_home = helper.instance_variable_get(:@league_home)
    attributes = {
      game_id: @game.id, contest_id: @contest.id, approved_token_id: @token.id,
      players: Nfl::FantasyEntry::PLAYER_SLOTS.zip(@players.map(&:id)).to_h,
      squads: { quarterbacks: @game.home_team_id, defense: @game.away_team_id, special_teams: @game.home_team_id },
      league_pick_game_id: @league_game.id, league_pick_team_id: @league_home.id
    }
    @ticket = Nfl::FantasyEntry.new(user: @user, attributes: attributes).create!
    sign_in @user
  end

  test 'renders NFL index game and owned entry pages' do
    get nfl_fantasy_path
    assert_response :success
    get nfl_fantasy_game_path(@game)
    assert_response :success
    get nfl_fantasy_entry_path(@ticket)
    assert_response :success
    assert_includes response.body, "Entry ##{@ticket.id}"
  end

  test 'starts only the next question and persists a server timer' do
    question = ordered_questions.first
    post start_nfl_fantasy_question_path(@ticket, question), as: :json

    assert_response :success
    payload = response.parsed_body
    assert_equal question.id, payload['question_id']
    assert_equal false, payload['answered']
    assert_operator payload['remaining_seconds'], :<=, 14.0
    assert Nfl::QuestionAttempt.exists?(ticket: @ticket, question: question)
  end

  test 'expired answer is recorded once with zero time and no selected team' do
    question = ordered_questions.first
    post start_nfl_fantasy_question_path(@ticket, question), as: :json
    attempt = Nfl::QuestionAttempt.find_by!(ticket: @ticket, question: question)
    attempt.update_column(:started_at, 15.seconds.ago)

    post answer_nfl_fantasy_question_path(@ticket, question),
         params: { team_id: @game.home_team_id }, as: :json

    assert_response :success
    payload = response.parsed_body
    assert_equal true, payload['answered']
    assert_equal 0.0, payload['remaining_seconds']
    assert_equal ordered_questions.second.id, payload['next_question_id']
    answer = @ticket.answers.find_by!(question: question)
    assert_equal 0.0, answer.time
    assert_nil answer.answer
    assert Nfl::QuestionAttempt.find(attempt.id).completed_at?
  end

  test 'does not expose another users ticket endpoints' do
    other = User.create!(
      username: "other-#{SecureRandom.hex(3)}", email: "#{SecureRandom.hex(3)}@example.com",
      password: 'password123', password_confirmation: 'password123'
    )
    sign_out @user
    sign_in other

    get nfl_fantasy_entry_path(@ticket), as: :json
    assert_response :forbidden
    post start_nfl_fantasy_question_path(@ticket, ordered_questions.first), as: :json
    assert_response :forbidden
  end

  test 'legacy NFL fantasy routes redirect without entering MLB code' do
    get fantasy_path(sport: 'nfl')
    assert_redirected_to nfl_fantasy_path
    get fantasy_game_path(@game, sport: 'nfl')
    assert_redirected_to nfl_fantasy_game_path(@game)
    post fantasy_enter_contest_path, params: { sport: 'nfl', contest_id: @contest.id }
    assert_redirected_to nfl_fantasy_game_path(@game)
  end

  private

  def ordered_questions
    @ticket.questions.to_a.sort_by { |question| [question.is_a?(BestQuestion) ? 0 : 1, question.id] }
  end
end