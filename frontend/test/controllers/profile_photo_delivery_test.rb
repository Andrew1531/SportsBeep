require 'test_helper'
require 'minitest/mock'
require 'base64'

class ProfilePhotoDeliveryTest < ActionDispatch::IntegrationTest
  test 'profile photo proxy returns the original image without an expiring disk redirect' do
    png = Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/l9sAAAAASUVORK5CYII=')
    user = User.create!(
      username: 'photo-delivery-test', email: 'photo-delivery@example.test',
      password: 'test-password-123', password_confirmation: 'test-password-123'
    )
    user.profile_photo.attach(io: StringIO.new(png), filename: 'portrait.png', content_type: 'image/png')
    path = Rails.application.routes.url_helpers.rails_storage_proxy_path(user.profile_photo, only_path: true)

    get path

    assert_response :success
    assert_equal 'image/png', response.media_type
    assert_equal png.b, response.body.b
    assert_nil response.headers['Location']
  ensure
    user&.profile_photo&.purge if user&.profile_photo&.attached?
  end
end