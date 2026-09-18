class Admin::WalletsController < Admin::BaseController
  def index
    @search = params[:search].to_s.strip.first(200)
    @verification = params[:verification].to_s
    unless ['', 'verified', 'unverified'].include?(@verification)
      raise ActionController::BadRequest, 'Invalid wallet verification filter'
    end

    @has_ethereum = User.column_names.include?('ethereum_wallet_address')
    wallet_sql = "NULLIF(users.cardano_wallet_address, '') IS NOT NULL"
    wallet_sql += " OR NULLIF(users.ethereum_wallet_address, '') IS NOT NULL" if @has_ethereum
    historical_users = BeepChainTransfer.where.not(destination_address: [nil, '']).select(:user_id)
    @users = User.where(wallet_sql).or(User.where(id: historical_users))
    if @search.present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(@search)}%"
      columns = %w[email username cardano_wallet_address cardano_stake_address]
      columns << 'ethereum_wallet_address' if @has_ethereum
      @users = @users.where(columns.map { |column| "users.#{column} LIKE :term" }.join(' OR '), term: term)
    end
    @users = @users.where.not(cardano_wallet_verified_at: nil) if @verification == 'verified'
    @users = @users.where(cardano_wallet_verified_at: nil) if @verification == 'unverified'
    @count = @users.count
    @users = @users.order(id: :desc).page(params[:page]).per(25)
  end

  def show
    @user = User.find(params[:id])
    account = Account.find_by(user_id: @user.id)
    @balances = account ? AccountTokenBalance.where(account_id: account.id).includes(:approved_token) : []
    @historical_addresses = @user.beep_chain_transfers.where.not(destination_address: [nil, ''])
      .distinct.order(:destination_address).pluck(:destination_address)
    @transfers = @user.beep_chain_transfers.includes(:approved_token).order(id: :desc).page(params[:page]).per(25)
  end
end