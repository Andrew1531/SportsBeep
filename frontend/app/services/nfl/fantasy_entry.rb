class Nfl::FantasyEntry
  PLAYER_SLOTS = %w[running_back tight_end wide_receiver kicker flex_player].freeze
  SQUAD_SLOTS = %w[quarterbacks defense special_teams].freeze

  class EntryError < StandardError; end

  def initialize(user:, attributes:)
    @user = user
    @attributes = attributes.to_h.with_indifferent_access
  end

  def create!
    raise EntryError, SportsbookOnly::MESSAGE
    game = Nfl::Game.find(@attributes[:game_id])
    token = ApprovedToken.enabled.find_by(id: @attributes[:approved_token_id])
    raise EntryError, 'Choose an enabled approved token.' unless token

    ActiveRecord::Base.transaction do
      game.with_lock do
        raise EntryError, 'This game has already started.' unless game.start_time.future?
        contest = locked_contest_for!(game)
        validate_questions!(contest)
        validate_contest!(contest)
        validate_league_pick!(game)

        roster_attributes = normalized_roster!
        ticket = Nfl::Ticket.new(
          contest: contest, user: @user, approved_token: token,
          league_pick_game_id: @attributes[:league_pick_game_id],
          league_pick_team_id: @attributes[:league_pick_team_id]
        )
        ticket.roster = Nfl::TicketRoster.new(ticket, roster_attributes)
        ticket.entry_fee_units = token.parse_amount!(contest.pool.entry_fee.to_s)
        ticket.save!
        ticket.roster.save
        debit!(ticket, contest.pool)
        ticket
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    raise EntryError, e.record.errors.full_messages.to_sentence
  rescue ActiveRecord::RecordNotFound
    raise EntryError, 'The selected game, contest, or player was not found.'
  rescue TokenAmount::InvalidAmount, AccountTokenBalance::InsufficientBalance => e
    raise EntryError, e.message
  end

  def update!(ticket)
    raise EntryError, SportsbookOnly::MESSAGE
    ActiveRecord::Base.transaction do
      ticket.game.with_lock do
        ticket.lock!
        raise EntryError, 'This entry can no longer be changed.' unless ticket.editable_by?(@user)
        validate_league_pick!(ticket.game)
        ticket.roster = Nfl::TicketRoster.new(ticket, normalized_roster!)
        ticket.player_ids = ticket.roster.player_ids
        ticket.assign_attributes(
          league_pick_game_id: @attributes[:league_pick_game_id],
          league_pick_team_id: @attributes[:league_pick_team_id]
        )
        ticket.save!
        ticket.roster.save
        ticket
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    raise EntryError, e.record.errors.full_messages.to_sentence
  rescue ActiveRecord::RecordNotFound
    raise EntryError, 'The selected player was not found.'
  end

  private

  def locked_contest_for!(game)
    if @attributes[:contest_id].present?
      contest = Nfl::Contest.find(@attributes[:contest_id])
      raise EntryError, 'That contest is not for this game.' unless contest.game == game
      contest.lock!
      contest
    else
      pool = game.pools.find_by(id: @attributes[:pool_id])
      raise EntryError, 'Choose a pool for this game.' unless pool
      template = game.contest_templates.find_by(pool: pool)
      raise EntryError, 'No contest template exists for that pool.' unless template
      template.with_lock do
        template.contests.open.lock(true).first || template.contests.create!(type: 'Nfl::Contest')
      end
    end
  end

  def validate_contest!(contest)
    maximum = contest.pool.max_tickets_per_contest
    raise EntryError, 'That contest is full.' if maximum && contest.tickets.count >= maximum
    if contest.tickets.where(user: @user).exists?
      raise EntryError, 'You cannot join the same contest twice.'
    end
  end

  def validate_questions!(contest)
    questions = contest.questions.to_a
    best = questions.count { |question| question.is_a?(BestQuestion) }
    bust = questions.count { |question| question.is_a?(BustQuestion) }
    raise EntryError, 'This contest is not configured with exactly 3 Best and 3 Bust questions.' unless best == 3 && bust == 3 && questions.size == 6
  end

  def validate_league_pick!(game)
    game_id = @attributes[:league_pick_game_id]
    team_id = @attributes[:league_pick_team_id]
    return if game_id.blank? && team_id.blank?
    raise EntryError, 'Choose both a league-pick game and team.' if game_id.blank? || team_id.blank?

    selected_game = game.league_picks.find_by(id: game_id)
    raise EntryError, 'That league-pick game is not available for this matchup.' unless selected_game
    unless selected_game.teams.any? { |team| team.id == team_id.to_i }
      raise EntryError, 'The league-pick team must play in the selected league-pick game.'
    end
  end

  def normalized_roster!
    player_params = hash_param(:players)
    squad_params = hash_param(:squads)
    unless player_params.keys.sort == PLAYER_SLOTS.sort && squad_params.keys.sort == SQUAD_SLOTS.sort
      raise EntryError, 'Every player and squad slot must be selected.'
    end

    player_ids = PLAYER_SLOTS.map { |slot| integer_id!(player_params[slot], slot) }
    raise EntryError, 'Each player may only be selected once.' unless player_ids.uniq.size == PLAYER_SLOTS.size

    {
      players: PLAYER_SLOTS.zip(player_ids).map { |slot, id| { position: slot, id: id } },
      squads: SQUAD_SLOTS.map { |slot| { position: slot, id: integer_id!(squad_params[slot], slot) } }
    }
  end

  def hash_param(name)
    value = @attributes[name]
    raise EntryError, "Missing #{name}." unless value.respond_to?(:to_h)
    value.to_h.stringify_keys
  end

  def integer_id!(value, name)
    id = Integer(value, exception: false)
    raise EntryError, "Choose a valid #{name.to_s.tr('_', ' ')}." unless id&.positive?
    id
  end

  def debit!(ticket, pool)
    units = ticket.entry_fee_units.to_i
    return if units.zero?

    account = @user.account
    raise EntryError, 'Your account is unavailable.' unless account
    account.with_lock do
      balance = account.token_balance_for(ticket.approved_token)
      if balance.balance_units.to_i < units
        raise AccountTokenBalance::InsufficientBalance, "Insufficient #{ticket.approved_token.ticker} balance."
      end
      balance.update!(balance_units: balance.balance_units.to_i - units)
      ContestEntryFeeTransaction.create!(
        account: account, approved_token: ticket.approved_token, amount_units: -units,
        amount_cents: 0, description: "Contest entry fee — #{pool.name}", status: 'completed'
      )
    end
  end
end