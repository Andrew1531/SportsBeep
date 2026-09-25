class EnterContest

  attr_reader :ticket

  def initialize(ticket)
    @ticket = ticket
  end

  def call(game, pool)
    SportsbookOnly.reject!
    template = pool.contest_templates.find_by game: game
    if template.present?
      ticket.contest = template.contests.open.where.not(id: ticket.user.contests(sport).pluck(:id)).take || template.contests.create(type: "#{sport}::Contest")
      debit_entry_token!(pool)
      clone_errors_from_contest if ticket.contest.invalid?
    else
      ticket.errors.add(:base, 'No contests exist for the selected game & pool')
    end
  end

  def call!(game, pool)
    SportsbookOnly.reject!
    call game, pool
    ticket.save!
  end

  private

    def sport
      ticket.class.name[/(Mlb|Nfl)/]
    end

    def clone_errors_from_contest
      ticket.contest.errors.full_messages.each do |message|
        ticket.errors.add(:contests, message)
      end
    end

    def debit_entry_token!(pool)
      token = ticket.approved_token
      raise TokenAmount::InvalidAmount, 'Choose an enabled approved token to enter this contest.' unless token&.enabled?

      ticket.entry_fee_units ||= token.parse_amount!(pool.entry_fee.to_s)
      units = ticket.entry_fee_units.to_i
      return if units.zero?
      account = ticket.user.account
      account.with_lock do
        balance = account.token_balance_for(token)
        raise AccountTokenBalance::InsufficientBalance, "Insufficient #{token.ticker} balance." if balance.balance_units.to_i < units
        balance.update!(balance_units: balance.balance_units.to_i - units)
        ContestEntryFeeTransaction.create!(
          account: account, approved_token: token, amount_units: -units,
          amount_cents: 0, description: "Contest entry fee for #{token.ticker}", status: 'completed'
        )
      end
    end

end