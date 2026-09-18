class AdminActivityReport
  PAGE_SIZE = 25
  OPEN_WAGER_STATUSES = %w[pending active].freeze

  attr_reader :params, :tokens, :selected_token, :legacy

  def initialize(params = {})
    @params = params.to_h.with_indifferent_access
    @tokens = ApprovedToken.order(:ticker, :id).to_a
    @legacy = @params[:token] == 'legacy'
    @selected_token = tokens.find { |token| token.id.to_s == @params[:token].to_s }
    @selected_token ||= tokens.first unless legacy
  end

  def call
    wagers = filter_wagers(token_scope(Wager.all))
    entries = filter_entries(token_scope(Ticket.all))

    {
      generated_at: Time.current,
      tokens: tokens,
      selected_token: selected_token,
      legacy: legacy,
      totals: totals,
      balance_leaders: balance_leaders,
      stake_leaders: stake_leaders,
      games: game_rows(wagers),
      contests: contest_rows(entries),
      wagers: page(wagers.includes(:user, :approved_token).order(created_at: :desc), :page),
      wager_count: wagers.count,
      entries: page(entries.includes(:user, :approved_token, contest: { template: [:game, :pool] }).order(created_at: :desc), :entry_page),
      entry_count: entries.count,
      page: page_number(:page),
      entry_page: page_number(:entry_page),
      page_size: PAGE_SIZE
    }
  end

  private

  def token_scope(scope)
    return scope.where(approved_token_id: nil) if legacy
    return scope.none unless selected_token

    scope.where(approved_token_id: selected_token.id)
  end

  def totals
    balances = selected_token ? AccountTokenBalance.where(approved_token_id: selected_token.id) : AccountTokenBalance.none
    open_wagers = token_scope(Wager.where(status: OPEN_WAGER_STATUSES))
    active_entries = active_entry_scope(token_scope(Ticket.all))
    {
      available_units: integer_sum(balances, :balance_units),
      open_wager_count: open_wagers.count,
      open_wager_stake: amount_sum(open_wagers, :amount_units, :amount_cents),
      open_potential_payout: amount_sum(open_wagers, :potential_payout_units, :potential_payout_cents),
      active_entry_count: active_entries.count,
      active_entry_stake: legacy ? nil : integer_sum(active_entries, :entry_fee_units)
    }
  end

  def balance_leaders
    return [] unless selected_token

    AccountTokenBalance.where(approved_token_id: selected_token.id)
      .joins(account: :user).includes(account: :user)
      .order(balance_units: :desc, id: :asc).limit(20).map do |balance|
        { user: balance.account.user, units: balance.balance_units.to_i }
      end
  end

  def stake_leaders
    wager_amounts = token_scope(Wager.where(status: OPEN_WAGER_STATUSES)).group(:user_id)
      .sum(legacy ? :amount_cents : :amount_units).transform_values(&:to_i)
    entry_amounts = if legacy
      {}
    else
      active_entry_scope(token_scope(Ticket.all)).group(:user_id).sum(:entry_fee_units).transform_values(&:to_i)
    end
    user_ids = (wager_amounts.keys + entry_amounts.keys).compact.uniq
    users = User.where(id: user_ids).index_by(&:id)
    user_ids.map do |user_id|
      wager = wager_amounts[user_id].to_i
      fantasy = entry_amounts[user_id].to_i
      { user: users[user_id], wager_units: wager, fantasy_units: fantasy, total_units: wager + fantasy }
    end.select { |row| row[:user] }.sort_by { |row| [-row[:total_units], row[:user].id] }.first(20)
  end

  def active_entry_scope(scope)
    scope.joins(:contest).where('contests.status IS NULL OR contests.status != ?', 'finalized')
  end

  def filter_wagers(scope)
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where('LOWER(wagers.sport) = ?', params[:sport].to_s.downcase) if params[:sport].present?
    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
    scope = scope.where('wagers.game_id = ? OR wagers.fixture_id = ?', params[:game_id], params[:game_id]) if params[:game_id].present?
    if params[:team].present?
      team = "%#{ActiveRecord::Base.sanitize_sql_like(params[:team].to_s.downcase)}%"
      scope = scope.where('LOWER(wagers.home_team) LIKE ? OR LOWER(wagers.away_team) LIKE ?', team, team)
    end
    if params[:search].present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search].to_s.downcase)}%"
      scope = scope.joins(:user).where('LOWER(users.username) LIKE ? OR LOWER(users.email) LIKE ?', term, term)
    end
    scope
  end

  def filter_entries(scope)
    scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
    if params[:search].present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search].to_s.downcase)}%"
      scope = scope.joins(:user).where('LOWER(users.username) LIKE ? OR LOWER(users.email) LIKE ?', term, term)
    end
    if params[:game_id].present? || params[:team].present? || params[:sport].present?
      scope = scope.joins(contest: { template: :game })
      scope = scope.where(games: { id: params[:game_id] }) if params[:game_id].present?
      scope = scope.where('LOWER(games.type) LIKE ?', "%#{params[:sport].to_s.downcase}%") if params[:sport].present?
      if params[:team].present?
        term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:team].to_s.downcase)}%"
        team_ids = Team.where('LOWER(teams.name) LIKE ? OR LOWER(teams.market) LIKE ? OR LOWER(teams.abbr) LIKE ?', term, term, term).select(:id)
        scope = scope.where('games.home_team_id IN (?) OR games.away_team_id IN (?)', team_ids, team_ids)
      end
    end
    scope
  end

  def game_rows(scope)
    scope.group(:sport, :game_id, :fixture_id, :away_team, :home_team, :game_start_time, :status)
      .pluck(:sport, :game_id, :fixture_id, :away_team, :home_team, :game_start_time, :status,
             Arel.sql('COUNT(*)'), Arel.sql('COUNT(DISTINCT wagers.user_id)'),
             Arel.sql("COALESCE(SUM(#{legacy ? 'amount_cents' : 'amount_units'}), 0)"),
             Arel.sql("COALESCE(SUM(#{legacy ? 'potential_payout_cents' : 'potential_payout_units'}), 0)"))
      .map do |sport, game_id, fixture_id, away, home, start_time, status, bets, participants, stake, payout|
        {
          sport: sport, game_id: game_id, fixture_id: fixture_id, away_team: away, home_team: home,
          start_time: start_time, status: status, bets: bets.to_i, participants: participants.to_i,
          stake: stake.to_i, potential_payout: payout.to_i
        }
      end.sort_by { |row| [row[:start_time] ? 0 : 1, -(row[:start_time]&.to_i || 0), row[:game_id].to_s] }
  end

  def contest_rows(scope)
    grouped = scope.group(:contest_id).pluck(
      :contest_id,
      Arel.sql('COUNT(*)'),
      Arel.sql('COUNT(DISTINCT tickets.user_id)'),
      Arel.sql('COALESCE(SUM(tickets.entry_fee_units), 0)')
    )
    contests = Contest.includes(template: { game: [:home_team, :away_team] }).where(id: grouped.map(&:first)).index_by(&:id)
    grouped.map do |contest_id, entries, participants, stake|
      contest = contests[contest_id]
      game = contest&.game
      {
        contest: contest, game: game, entries: entries.to_i, participants: participants.to_i,
        entry_stake: legacy ? nil : stake.to_i
      }
    end.sort_by { |row| [row[:game]&.start_time ? 0 : 1, -(row[:game]&.start_time&.to_i || 0), row[:contest]&.id.to_i] }
  end

  def amount_sum(scope, units_column, cents_column)
    integer_sum(scope, legacy ? cents_column : units_column)
  end

  def integer_sum(scope, column)
    scope.sum(column).to_i
  end

  def page(scope, key)
    scope.offset((page_number(key) - 1) * PAGE_SIZE).limit(PAGE_SIZE)
  end

  def page_number(key)
    [params[key].to_i, 1].max
  end
end