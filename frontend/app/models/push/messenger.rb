class Push
  class Messenger
    include Sidekiq::Worker
    include ActiveModel::Model

    attr_accessor :device_token
    attr_accessor :platform
    attr_accessor :body

    validates :device_token, presence: true
    validates :platform, presence: true

    def perform(user_id, body)
      @user = User.find(user_id)
      return unless @user
      @device_token = @user.device_token
      @platform = @user.platform
      @body = body
      deliver
    end

    def deliver
      return unless valid?
      return if ENV.key?('DISABLE_PUSH')
      case platform.intern
      when :ios
        APNS.send_notification [device_token], body
      when :android
        GCM.send_notification [device_token], body
      end
    end

  end
end