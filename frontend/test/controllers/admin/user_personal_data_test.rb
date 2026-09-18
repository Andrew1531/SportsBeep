require 'test_helper'

class Admin::UserPersonalDataTest < ActionDispatch::IntegrationTest
  setup do
    https!
    @admin = Administrator.create!(
      email: 'personal-data-admin@example.test',
      password: 'administrator-password',
      password_confirmation: 'administrator-password'
    )
    @user = User.create!(
      email: 'personal-data-user@example.test',
      username: 'personal-data-user',
      password: 'user-password-123',
      password_confirmation: 'user-password-123'
    )
    @paths = [
      [:get, edit_admin_user_path(@user)],
      [:patch, update_personal_info_admin_user_path(@user)],
      [:post, remove_personal_info_admin_user_path(@user)]
    ]
  end

  test 'anonymous visitors cannot access personal data actions' do
    @paths.each do |verb, path|
      public_send(verb, path)
      assert_redirected_to new_administrator_session_path
    end
  end

  test 'ordinary users cannot access personal data actions' do
    sign_in @user
    @paths.each do |verb, path|
      public_send(verb, path)
      assert_redirected_to new_administrator_session_path
    end
  end

  test 'administrator correction succeeds through the dedicated endpoint' do
    sign_in @admin
    get edit_admin_user_path(@user)
    assert_response :success
    assert_select 'input[name="user[address_attributes][country]"]'
    patch update_personal_info_admin_user_path(@user), params: {
      user: {
        email: 'controller-corrected@example.test',
        username: @user.username,
        first_name: 'Corrected',
        last_name: '',
        reason: 'Approved support correction',
        address_attributes: { city: 'Corrected City' }
      }
    }

    assert_redirected_to admin_user_path(@user)
    assert_equal 'controller-corrected@example.test', @user.reload.email
    assert_equal 'personal_info_corrected', AdminAuditEvent.last.action
  end

  test 'existing update endpoint still resets password and now audits its reason' do
    sign_in @admin
    patch admin_user_path(@user), params: {
      user: { password: 'new-user-password-123', reason: 'Approved password reset' }
    }

    assert_redirected_to admin_user_path(@user)
    assert @user.reload.valid_password?('new-user-password-123')
    assert_equal 'password_reset', AdminAuditEvent.last.action
    assert_equal ['password'], AdminAuditEvent.last.changed_fields
  end
end