require 'test_helper'

class AdminAccessTest < ActionDispatch::IntegrationTest
  setup { https! }

  # Covers every active admin controller, including those outside Admin::BaseController.
  ADMIN_PAGES = %w[
    /admin /admin/dashboard /admin/administrators /admin/users
    /admin/promo_codes /admin/setting /admin/push/new
    /admin/approved_tokens /admin/swap_assets
    /admin/mlb/games /admin/nfl/games
    /admin/mlb/questions /admin/nfl/questions
  ].freeze

  test 'anonymous visitors cannot access any administrative section' do
    ADMIN_PAGES.each { |path| assert_admin_rejected(path) }
    assert_admin_mutations_rejected
  end

  test 'ordinary user login never grants administrator access' do
    user = User.create!(
      email: 'crawler-user@example.test', username: 'crawler-user',
      password: 'test-password-123', password_confirmation: 'test-password-123'
    )
    sign_in user
    ADMIN_PAGES.each { |path| assert_admin_rejected(path) }
    assert_admin_mutations_rejected
  end

  test 'administrator login page remains reachable but never indexable or cacheable' do
    get '/administrators/login'
    assert_response :success
    assert_private_headers
    assert_select 'a', text: 'Forgot your password?', count: 0
    assert_select 'a', text: 'Create one now', count: 0
  end

  test 'authenticated administrators retain access with private response headers' do
    admin = Administrator.create!(
      email: 'crawler-admin@example.test', password: 'test-password-123',
      password_confirmation: 'test-password-123'
    )
    sign_in admin
    %w[/admin/administrators /admin/approved_tokens /admin/swap_assets].each do |path|
      get path
      assert_response :success
      assert_private_headers
    end
  end

  private

  def assert_admin_rejected(path)
    get path
    assert_redirected_to new_administrator_session_path
    assert_private_headers
  end

  def assert_admin_mutations_rejected
    [
      [:post, '/admin/administrators'],
      [:post, '/admin/approved_tokens'],
      [:patch, '/admin/swap_assets/1'],
      [:patch, '/admin/users/1'],
      [:delete, '/admin/administrators/1']
    ].each do |verb, path|
      public_send(verb, path)
      assert_redirected_to new_administrator_session_path
      assert_private_headers
    end
  end

  def assert_private_headers
    assert_includes response.headers.fetch('X-Robots-Tag'), 'noindex'
    assert_includes response.headers.fetch('Cache-Control'), 'no-store'
  end
end