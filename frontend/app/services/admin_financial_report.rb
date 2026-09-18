class AdminFinancialReport
  OPEN_WAGER_STATUSES = %w[pending active].freeze
  SETTLED_WAGER_STATUSES = %w[won lost push].freeze
  DEPOSIT_TERMINAL_STATUSES = %w[credited failed].freeze
  WITHDRAWAL_TERMINAL_STATUSES = %w[confirmed failed].freeze

  def call
    tokens = ApprovedToken.order(:ticker, :id).to_a

    {
      generated_at: Time.current,
      tokens: tokens.map { |token| token_row(token) },
      transfers: transfer_rows(tokens),
      swap_obligations: swap_rows
    }
  end

  private

  def token_row(token)
    balances = AccountTokenBalance.where(approved_token_id: token.id)
    open_wagers = Wager.where(approved_token_id: token.id, status: OPEN_WAGER_STATUSES)

    {
      token: token,
      available_balance_units: integer_sum(balances, :balance_units),
      loaded_units: integer_sum(balances, :loaded_units),
      open_wagers: OPEN_WAGER_STATUSES.index_with do |status|
        scope = open_wagers.where(status: status)
        {
          count: scope.count,
          stake_units: integer_sum(scope, :amount_units),
          potential_payout_units: integer_sum(scope, :potential_payout_units)
        }
      end,
      settled_wagers: SETTLED_WAGER_STATUSES.index_with do |status|
        settled_wager_row(token, status)
      end
    }
  end

  def settled_wager_row(token, status)
    scope = Wager.where(approved_token_id: token.id, status: status)
    stake = integer_sum(scope, :amount_units)
    payout = case status
             when 'won' then integer_sum(scope, :potential_payout_units)
             when 'push' then stake
             else 0
             end
    { count: scope.count, stake_units: stake, payout_units: payout }
  end

  def transfer_rows(tokens)
    tokens.flat_map do |token|
      BeepChainTransfer::DIRECTIONS.flat_map do |direction|
        terminal = direction == 'deposit' ? DEPOSIT_TERMINAL_STATUSES : WITHDRAWAL_TERMINAL_STATUSES
        scope = BeepChainTransfer.where(approved_token_id: token.id, direction: direction)
                                 .where.not(status: terminal)
        scope.group(:status).sum(:amount_units).map do |status, units|
          {
            token: token,
            direction: direction,
            status: status,
            count: scope.where(status: status).count,
            units: units.to_i
          }
        end
      end
    end
  end

  def swap_rows
    CardanoSwap.group(:status, :payout_method).pluck(
      :status,
      :payout_method,
      Arel.sql('COUNT(*)'),
      Arel.sql('COALESCE(SUM(beep_amount), 0)')
    ).map do |status, payout_method, count, units|
      { status: status, payout_method: payout_method, count: count.to_i, beep_units: units.to_i }
    end
  end

  def integer_sum(scope, column)
    scope.sum(column).to_i
  end
end