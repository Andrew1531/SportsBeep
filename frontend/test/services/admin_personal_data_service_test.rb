require 'test_helper'

class AdminPersonalDataServiceTest < ActiveSupport::TestCase
  setup do
    @admin = Administrator.create!(
      email: 'privacy-admin@example.test',
      password: 'administrator-password',
      password_confirmation: 'administrator-password'
    )
    @user = User.create!(
      email: 'privacy-user@example.test',
      username: 'privacy-user',
      first_name: 'Before',
      last_name: 'Person',
      password: 'user-password-123',
      password_confirmation: 'user-password-123',
      cardano_wallet_address: 'addr1-current-wallet',
      cardano_stake_address: 'stake1-current-wallet',
      cardano_wallet_name: 'Personal wallet',
      cardano_wallet_verified_at: Time.current,
      device_token: 'personal-device-token',
      platform: 'ios',
      address_attributes: {
        line_one: '1 Before Street', city: 'Old City', state: 'CA',
        zip: '90001', country: 'US'
      }
    )
  end

  test 'authorized correction changes only permitted personal fields and audits names' do
    service(reason: 'Customer-approved correction').correct!(
      email: 'corrected@example.test',
      username: 'corrected-user',
      first_name: 'Corrected',
      address_attributes: { line_one: '2 Corrected Street', city: 'New City' },
      authentication_token: 'must-not-change',
      disabled: true
    )

    @user.reload
    assert_equal 'corrected@example.test', @user.email
    assert_equal 'corrected-user', @user.username
    assert_equal '2 Corrected Street', @user.address.line_one
    refute @user.disabled?
    refute_equal 'must-not-change', @user.authentication_token

    event = AdminAuditEvent.last
    assert_equal @admin, event.actor
    assert_equal @user, event.user
    assert_equal 'personal_info_corrected', event.action
    assert_equal %w[address.city address.line_one email first_name username], event.changed_fields
    refute_includes event.changed_fields.to_yaml, 'Before'
    refute_includes event.changed_fields.to_yaml, 'privacy-user@example.test'
  end

  test 'validation failure rolls personal and address changes back without audit' do
    User.create!(
      email: 'taken@example.test', username: 'taken-name',
      password: 'user-password-123', password_confirmation: 'user-password-123'
    )

    assert_no_difference('AdminAuditEvent.count') do
      assert_raises(ActiveRecord::RecordInvalid) do
        service(reason: 'Correction request').correct!(
          username: 'taken-name',
          address_attributes: { city: 'Should Roll Back' }
        )
      end
    end

    assert_equal 'privacy-user', @user.reload.username
    assert_equal 'Old City', @user.address.reload.city
  end

  test 'wrong administrator password and confirmation reject removal' do
    assert_raises(AdminPersonalDataService::ConfirmationError) do
      service(reason: 'Verified removal request').remove!(
        admin_password: 'wrong-password', confirmation: 'REMOVE'
      )
    end
    assert_raises(AdminPersonalDataService::ConfirmationError) do
      service(reason: 'Verified removal request').remove!(
        admin_password: 'administrator-password', confirmation: 'remove'
      )
    end

    refute @user.reload.disabled?
    assert_equal 'privacy-user@example.test', @user.email
    assert_equal 0, AdminAuditEvent.where(action: 'personal_info_removed').count
  end

  test 'anonymization disables login and preserves account and forensic financial history' do
    account_id = @user.account.id
    transaction = AdjustmentTransaction.new(
      account: @user.account, amount_cents: 0, description: 'Historical adjustment'
    )
    transaction.save!(validate: false)
    transfer = BeepChainTransfer.create!(
      user: @user,
      direction: 'withdrawal',
      amount_beep: 5,
      status: 'confirmed',
      request_key: 'historical-removal-transfer',
      destination_address: 'addr1-historical-destination',
      tx_hash: 'c' * 64
    )
    original_token = @user.authentication_token
    original_password = @user.encrypted_password

    service(reason: 'Verified erasure request').remove!(
      admin_password: 'administrator-password', confirmation: 'REMOVE'
    )

    @user.reload
    assert @user.disabled?
    assert @user.personal_data_removed_at
    assert_match(/\Aremoved-\d+-[0-9a-f]+@removed\.invalid\z/, @user.email)
    assert_match(/\Aremoved-user-\d+-[0-9a-f]+\z/, @user.username)
    assert_nil @user.first_name
    assert_nil @user.address
    assert_nil @user.cardano_wallet_address
    assert_nil @user.cardano_stake_address
    refute_equal original_token, @user.authentication_token
    refute_equal original_password, @user.encrypted_password
    refute @user.valid_password?('user-password-123')
    assert_equal account_id, @user.account.id
    assert Transaction.exists?(transaction.id)
    assert_equal 'addr1-historical-destination', transfer.reload.destination_address

    event = AdminAuditEvent.last
    assert_equal 'personal_info_removed', event.action
    refute_includes event.changed_fields.to_yaml, 'addr1-current-wallet'
    refute_includes event.changed_fields.to_yaml, 'privacy-user@example.test'
  end

  test 'outstanding funds and obligations block anonymization without partial changes' do
    @user.account.update!(balance_cents: 100)
    BeepChainTransfer.create!(
      user: @user,
      direction: 'deposit',
      amount_beep: 5,
      status: 'pending'
    )

    error = assert_raises(AdminPersonalDataService::SafetyError) do
      service(reason: 'Verified erasure request').remove!(
        admin_password: 'administrator-password', confirmation: 'REMOVE'
      )
    end

    assert_includes error.message, 'nonzero balance'
    assert_includes error.message, 'pending/uncertain'
    refute @user.reload.disabled?
    assert_equal 'privacy-user@example.test', @user.email
    assert_equal 0, AdminAuditEvent.where(action: 'personal_info_removed').count
  end

  test 'confirmed uncredited deposits and unfinalized fantasy tickets are blockers' do
    BeepChainTransfer.create!(
      user: @user,
      direction: 'deposit',
      amount_beep: 5,
      status: 'confirmed',
      tx_hash: 'd' * 64
    )
    contest = Contest.new(status: 'open')
    contest.save!(validate: false)
    Ticket.insert_all!([{ user_id: @user.id, contest_id: contest.id, created_at: Time.current, updated_at: Time.current }])

    error = assert_raises(AdminPersonalDataService::SafetyError) do
      service(reason: 'Verified erasure request').remove!(
        admin_password: 'administrator-password', confirmation: 'REMOVE'
      )
    end

    assert_includes error.message, 'deposit is awaiting credit'
    assert_includes error.message, 'unfinalized fantasy ticket'
    refute @user.reload.disabled?
  end

  private

  def service(reason:)
    AdminPersonalDataService.new(actor: @admin, user: @user, reason: reason)
  end
end