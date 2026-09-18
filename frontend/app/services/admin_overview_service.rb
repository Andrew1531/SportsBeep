class AdminOverviewService
  OPEN_WAGER_STATUSES = %w[pending active].freeze
  UNRESOLVED_SWAP_STATUSES = %w[pending confirmed paying unknown].freeze
  DEPOSIT_TERMINAL_STATUSES = %w[credited failed].freeze
  WITHDRAWAL_TERMINAL_STATUSES = %w[confirmed failed].freeze

  def initialize(snapshot_service: -> { TreasurySnapshotService.new })
    @snapshot_service = snapshot_service
  end

  def call
    tokens = ApprovedToken.order(:ticker, :id).to_a
    balances = grouped_sum(AccountTokenBalance.all, :balance_units)
    wager_scope = Wager.where(status: OPEN_WAGER_STATUSES)
    wager_stakes = grouped_sum(wager_scope, :amount_units)
    wager_payouts = grouped_sum(wager_scope, :potential_payout_units)
    wager_counts = grouped_count(wager_scope)
    entry_scope = active_entries
    entry_stakes = grouped_sum(entry_scope, :entry_fee_units)
    entry_counts = grouped_count(entry_scope)
    deposits = outstanding_transfers('deposit')
    withdrawals = outstanding_transfers('withdrawal')
    deposit_units = grouped_sum(deposits, :amount_units)
    withdrawal_units = grouped_sum(withdrawals, :amount_units)
    unresolved_swaps = CardanoSwap.where(status: UNRESOLVED_SWAP_STATUSES)

    {
      generated_at: Time.current,
      treasury: @snapshot_service.call.call(tokens: tokens),
      tokens: tokens.map do |token|
        {
          token: token,
          available_units: balances[token.id].to_i,
          sportsbook_stake_units: wager_stakes[token.id].to_i,
          potential_payout_units: wager_payouts[token.id].to_i,
          open_wager_count: wager_counts[token.id].to_i,
          fantasy_stake_units: entry_stakes[token.id].to_i,
          active_entry_count: entry_counts[token.id].to_i,
          pending_deposit_units: deposit_units[token.id].to_i,
          pending_withdrawal_units: withdrawal_units[token.id].to_i
        }
      end,
      unresolved_swap_count: unresolved_swaps.count,
      unresolved_swap_beep_units: unresolved_swaps.sum(:beep_amount).to_i,
      legacy_unclassified_count: wager_scope.where(approved_token_id: nil).count +
        entry_scope.where(approved_token_id: nil).count +
        deposits.where(approved_token_id: nil).count +
        withdrawals.where(approved_token_id: nil).count
    }
  end

  private

  def active_entries
    Ticket.left_joins(:contest)
      .where('contests.id IS NULL OR contests.status IS NULL OR contests.status != ?', 'finalized')
  end

  def outstanding_transfers(direction)
    terminal_statuses = direction == 'deposit' ? DEPOSIT_TERMINAL_STATUSES : WITHDRAWAL_TERMINAL_STATUSES
    BeepChainTransfer.where(direction: direction).where.not(status: terminal_statuses)
  end

  def grouped_sum(scope, column)
    scope.where.not(approved_token_id: nil).group(:approved_token_id).sum(column).transform_values(&:to_i)
  end

  def grouped_count(scope)
    scope.where.not(approved_token_id: nil).group(:approved_token_id).count.transform_values(&:to_i)
  end
end