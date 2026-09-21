class NflFantasyController < ApplicationController
  QUESTION_SECONDS = 14.0
  PLAYER_SLOTS = Nfl::FantasyEntry::PLAYER_SLOTS
  SQUAD_SLOTS = Nfl::FantasyEntry::SQUAD_SLOTS

  before_action :authenticate_user!
  before_action :find_owned_ticket, only: [:entry, :update, :start_question, :answer_question]

  def index
    @games = Nfl::Game.includes(:home_team, :away_team)
                      .where('start_time >= ? OR status = ?', Time.current, 'live')
                      .order(:start_time)
    @past_games = Nfl::Game.includes(:home_team, :away_team).past.limit(20)
    @tickets = Nfl::Ticket.where(user: current_user).includes(contest: { template: [:game, :pool] }).order(created_at: :desc)
    @approved_tokens = ApprovedToken.enabled.order(:ticker)
  end

  def show
    @game = Nfl::Game.includes(:home_team, :away_team).find(params[:id])
    @players = @game.players.where(on_current_roster: true).order(:position, :last_name, :first_name)
    @contests = Nfl::Contest.includes(template: :pool).joins(:template)
                            .where(contest_templates: { game_id: @game.id })
    @pools = @game.pools
    @league_pick_games = @game.league_picks.includes(:home_team, :away_team).order(:start_time)
    @approved_tokens = ApprovedToken.enabled.order(:ticker)
    @player_slots = PLAYER_SLOTS
    @squad_slots = SQUAD_SLOTS
    @ticket = current_user.tickets.where(type: 'Nfl::Ticket').find_by(id: params[:ticket_id]) if params[:ticket_id].present?
  end

  def create
    @ticket = Nfl::FantasyEntry.new(user: current_user, attributes: entry_params).create!
    redirect_to nfl_fantasy_entry_path(@ticket), notice: 'Your NFL fantasy entry is ready.'
  rescue Nfl::FantasyEntry::EntryError => e
    redirect_to nfl_fantasy_game_path(params[:game_id]), alert: e.message
  end

  def entry
    load_entry
  end

  def update
    Nfl::FantasyEntry.new(user: current_user, attributes: entry_params).update!(@ticket)
    redirect_to nfl_fantasy_entry_path(@ticket), notice: 'Your NFL roster was updated.'
  rescue Nfl::FantasyEntry::EntryError => e
    redirect_to nfl_fantasy_entry_path(@ticket), alert: e.message
  end

  def start_question
    payload = nil
    @ticket.with_lock do
      question = ticket_question!
      expire_attempts!
      ensure_next_question!(question)
      attempt = @ticket.question_attempts.find_or_create_by!(question: question) { |record| record.started_at = Time.current }
      payload = attempt_payload(attempt)
    end
    render json: payload
  rescue ActiveRecord::RecordNotUnique
    retry
  rescue Nfl::FantasyEntry::EntryError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def answer_question
    result = nil
    @ticket.with_lock do
      question = ticket_question!
      requested_attempt = @ticket.question_attempts.lock.find_by(question_id: question.id)
      requested_expired = requested_attempt && !requested_attempt.completed_at? &&
                          remaining_seconds(requested_attempt).zero?
      expire_attempts!
      if requested_expired
        next_question = ordered_questions.detect { |candidate| !@ticket.answers.exists?(question_id: candidate.id) }
        result = { answered: true, next_question_id: next_question&.id, remaining_seconds: 0.0 }
      else
        ensure_next_question!(question)
        attempt = @ticket.question_attempts.lock.find_by(question_id: question.id)
        raise Nfl::FantasyEntry::EntryError, 'Start this question before answering it.' unless attempt
        raise Nfl::FantasyEntry::EntryError, 'This question has already been answered.' if attempt.completed_at?

        remaining = remaining_seconds(attempt)
        answer_team = selected_team(remaining)
        QuestionAnswer.create!(ticket: @ticket, question: question, answer: answer_team, time: remaining)
        attempt.update!(completed_at: Time.current)
        next_question = ordered_questions.detect { |candidate| !@ticket.answers.exists?(question_id: candidate.id) }
        result = { answered: true, next_question_id: next_question&.id, remaining_seconds: remaining }
      end
    end
    render json: result
  rescue ActiveRecord::RecordInvalid, Nfl::FantasyEntry::EntryError => e
    message = e.respond_to?(:record) ? e.record.errors.full_messages.to_sentence : e.message
    render json: { error: message }, status: :unprocessable_entity
  end

  private

  def find_owned_ticket
    @ticket = Nfl::Ticket.find(params[:id])
    return if @ticket.user == current_user

    render json: { error: 'You do not have access to this entry.' }, status: :forbidden
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Entry not found.' }, status: :forbidden
  end

  def entry_params
    params.permit(
      :game_id, :contest_id, :pool_id, :approved_token_id,
      :league_pick_game_id, :league_pick_team_id,
      players: PLAYER_SLOTS, squads: SQUAD_SLOTS
    )
  end

  def load_entry
    @game = @ticket.game
    @questions = ordered_questions
    @answers = @ticket.answers.index_by(&:question_id)
    @question_attempts = @ticket.question_attempts.index_by(&:question_id)
    @leaderboard = @ticket.contest.tickets.includes(:players, :ticket_squads).to_a.sort_by do |ticket|
      score = safe_score { ticket.score! }
      score.nil? ? [1, 0] : [0, -score]
    end
    players_score = safe_score { @ticket.stats.total }
    squads_score = safe_score { @ticket.ticket_squads.to_a.sum(&:score) }
    league_pick_score = safe_score { @ticket.league_pick.score }
    best_bust_score = safe_score { @ticket.answers.score }
    total = safe_score { @ticket.score! }
    @score_breakdown = {
      players: players_score, squads: squads_score, league_pick: league_pick_score,
      best_bust: best_bust_score, total: total
    }
    @player_slots = PLAYER_SLOTS
    @squad_slots = SQUAD_SLOTS
  end

  def safe_score
    yield
  rescue StandardError => e
    Rails.logger.warn("NFL fantasy score unavailable for ticket #{@ticket.id}: #{e.message}")
    nil
  end

  def ordered_questions
    @ordered_questions ||= @ticket.questions.to_a.sort_by do |question|
      [question.is_a?(BestQuestion) ? 0 : 1, question.id]
    end
  end

  def ticket_question!
    question = ordered_questions.detect { |candidate| candidate.id == params[:question_id].to_i }
    raise Nfl::FantasyEntry::EntryError, 'That question is not part of this entry.' unless question
    question
  end

  def ensure_next_question!(question)
    next_question = ordered_questions.detect { |candidate| !@ticket.answers.exists?(question_id: candidate.id) }
    raise Nfl::FantasyEntry::EntryError, 'All questions have been answered.' unless next_question
    raise Nfl::FantasyEntry::EntryError, 'Questions must be answered in order.' unless next_question == question
  end

  def expire_attempts!
    @ticket.question_attempts.lock.where(completed_at: nil).each do |attempt|
      next if remaining_seconds(attempt).positive?

      question = Question.find(attempt.question_id)
      QuestionAnswer.find_or_create_by!(ticket: @ticket, question: question) do |answer|
        answer.answer = nil
        answer.time = 0.0
      end
      attempt.update!(completed_at: Time.current)
    end
  end

  def remaining_seconds(attempt)
    [QUESTION_SECONDS - (Time.current - attempt.started_at), 0.0].max.round(3)
  end

  def selected_team(remaining)
    return nil unless remaining.positive? && params[:team_id].present?

    team_id = Integer(params[:team_id], exception: false)
    team = @ticket.game.teams.detect { |candidate| candidate.id == team_id }
    raise Nfl::FantasyEntry::EntryError, 'Choose the home or away team.' unless team
    team
  end

  def attempt_payload(attempt)
    {
      question_id: attempt.question_id,
      started_at: attempt.started_at.iso8601(3),
      expires_at: (attempt.started_at + QUESTION_SECONDS.seconds).iso8601(3),
      remaining_seconds: remaining_seconds(attempt),
      answered: attempt.completed_at? || @ticket.answers.exists?(question_id: attempt.question_id)
    }
  end
end