class Push
  class Message
    include Sidekiq::Worker
    include ActiveModel::Model

    def send_to(user, options = {})
      if options.fetch(:background, false)
        Background.push Push::Messenger, user.id, body
      else
        Push::Messenger.new.perform(user.id, body)
      end
    end

  end
end