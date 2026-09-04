ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  self.use_transactional_tests = true
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end