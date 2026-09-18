class AdminPersonalDataService
  class Error < StandardError; end
  class SafetyError < Error; end
  class ConfirmationError < Error; end

  PERSONAL_ATTRIBUTES = %i[email username first_name last_name].freeze
  ADDRESS_ATTRIBUTES = %i[line_one line_two city state zip country].freeze
  OUTSTANDING_TRANSFER_STATUSES = %w[pending submitting submitted unknown].freeze
  OUTSTANDING_SWAP_STATUSES = %w[pending confirmed paying unknown].freeze
  OPEN_WAGER_STATUSES = %w[pending active].freeze
  BALANCE_COLUMNS = %i[
    balance_cents promo_balance_cents clearing_expense_cents
    promo_earnings_cents referral_winnings_cents
  ].freeze
  def initialize(actor:, user:, reason:)
    @actor = actor
    @user = user
    @reason = reason.to_s.strip
  end

  def correct!(attributes)
    require_reason!
    requested = attributes.to_h.symbolize_keys.slice(*PERSONAL_ATTRIBUTES)
    address_requested = requested.delete(:address_attributes) || attributes.to_h[:address_attributes] ||
                        attributes.to_h['address_attributes']
    changed_fields = []

    User.transaction do
      @user.lock!
      requested.each do |field, value|
        next if @user.public_send(field).to_s == value.to_s

        @user.public_send("#{field}=", value)
        changed_fields << field.to_s
      end

      if address_requested
        address = @user.address || @user.build_address
        address_requested.to_h.symbolize_keys.slice(*ADDRESS_ATTRIBUTES).each do |field, value|
          next if address.public_send(field).to_s == value.to_s

          address.public_send("#{field}=", value)
          changed_fields << "address.#{field}"
        end
      end

      raise Error, 'No personal information changes were submitted.' if changed_fields.empty?

      @user.save!
      @user.address.save! if @user.address&.changed?
      audit!('personal_info_corrected', changed_fields)
    end

    @user
  end

  def reset_password!(password)
    require_reason!
    raise Error, 'Password cannot be blank.' if password.blank?

    User.transaction do
      @user.lock!
      @user.update!(password: password)
      audit!('password_reset', ['password'])
    end

    @user
  end

  def remove!(admin_password:, confirmation:)
    require_reason!
    unless confirmation.to_s == 'REMOVE'
      raise ConfirmationError, 'Type REMOVE exactly to confirm personal information removal.'
    end
    unless @actor.valid_password?(admin_password.to_s)
      raise ConfirmationError, 'Current administrator password is incorrect.'
    end

    purge_photo = false
    User.transaction do
      @user.lock!
      lock_financial_rows!
      blockers = anonymization_blockers
      raise SafetyError, blockers.join(' ') if blockers.any?

      purge_photo = @user.profile_photo.attached?
      changed_fields = anonymize_user!
      if @user.address
        changed_fields.concat(ADDRESS_ATTRIBUTES.map { |field| "address.#{field}" })
        @user.address.destroy!
      end
      if @user.facebook_auth
        changed_fields << 'facebook_auth.credentials'
        @user.facebook_auth.destroy!
      end
      if @user.twitter_auth
        changed_fields << 'twitter_auth.credentials'
        @user.twitter_auth.destroy!
      end
      changed_fields << 'profile_photo' if purge_photo
      if @user.favorite_team
        changed_fields << 'favorite_team'
        @user.favorite_team.destroy!
      end
      audit!('personal_info_removed', changed_fields)
    end

    @user.profile_photo.purge_later if purge_photo
    @user
  end

  private

  def require_reason!
    raise Error, 'A reason is required.' if @reason.blank?
  end

  def lock_financial_rows!
    @user.account&.lock!
    @user.account&.account_token_balances&.lock&.load
    @user.beep_chain_transfers.lock.load
    @user.cardano_swaps.lock.load
    @user.wagers.lock.load
    @user.tickets.lock.load
    @user.tickets.map(&:contest).compact.uniq.each(&:lock!)
    @user.account&.transactions&.lock&.load
  end

  def anonymization_blockers
    blockers = []
    account = @user.account
    if account && BALANCE_COLUMNS.any? { |column| account.public_send(column).to_i != 0 }
      blockers << 'The account has a nonzero balance; settle or withdraw all balances first.'
    end
    if account && account.account_token_balances.any? { |balance| balance.balance_units.to_i != 0 }
      blockers << 'The account has a nonzero token balance; settle or withdraw all token balances first.'
    end
    transfer_blocked = @user.beep_chain_transfers.any? do |transfer|
      OUTSTANDING_TRANSFER_STATUSES.include?(transfer.status) ||
        (transfer.direction == 'deposit' && transfer.status == 'confirmed')
    end
    if transfer_blocked
      blockers << 'A deposit is awaiting credit or a transfer is pending/uncertain; credit or reconcile it first.'
    end
    if @user.cardano_swaps.where(status: OUTSTANDING_SWAP_STATUSES).exists?
      blockers << 'A swap is pending or uncertain; reconcile it first.'
    end
    if @user.wagers.where(status: OPEN_WAGER_STATUSES).exists?
      blockers << 'The user has an open wager; settle or cancel it first.'
    end
    if @user.tickets.any? { |ticket| ticket.contest.nil? || ticket.contest.status != 'finalized' }
      blockers << 'The user has an unfinalized fantasy ticket; finalize its contest and prize obligations first.'
    end
    if account && account.transactions.where(
      type: %w[DepositTransaction WithdrawalTransaction],
      status: %w[pending unknown]
    ).exists?
      blockers << 'A legacy deposit or withdrawal is pending or uncertain; reconcile it first.'
    end
    blockers
  end

  def anonymize_user!
    suffix = "#{@user.id}-#{SecureRandom.hex(12)}"
    database_attributes = {
      email: "removed-#{suffix}@removed.invalid",
      username: "removed-user-#{suffix}",
      first_name: nil,
      last_name: nil,
      full_name: nil,
      date_of_birth: nil,
      gender: nil,
      avatar: nil,
      reset_password_token: nil,
      reset_password_sent_at: nil,
      remember_created_at: nil,
      current_sign_in_at: nil,
      last_sign_in_at: nil,
      current_sign_in_ip: nil,
      last_sign_in_ip: nil,
      confirmation_token: nil,
      confirmed_at: nil,
      confirmation_sent_at: nil,
      unconfirmed_email: nil,
      authentication_token: Devise.friendly_token,
      device_token: nil,
      platform: nil,
      avatar_uuid: nil,
      cardano_wallet_address: nil,
      ethereum_wallet_address: nil,
      cardano_stake_address: nil,
      cardano_wallet_name: nil,
      cardano_wallet_verified_at: nil,
      disabled: true,
      destroyed_at: Time.current,
      personal_data_removed_at: Time.current
    }.select { |field, _value| @user.has_attribute?(field) }
    @user.assign_attributes(database_attributes)
    @user.password = Devise.friendly_token(64)
    @user.save!(validate: false)
    database_attributes.keys.map(&:to_s) + ['password']
  end

  def audit!(action, changed_fields)
    AdminAuditEvent.create!(
      actor: @actor,
      user: @user,
      action: action,
      changed_fields: changed_fields.map(&:to_s).uniq.sort,
      reason: @reason
    )
  end
end