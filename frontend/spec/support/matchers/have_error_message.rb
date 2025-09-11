RSpec::Matchers.define :have_error_message do |message|
  match do |resource|
    resource.errors.full_messages.any? do |msg|
      case message
      when String
        msg == message
      else
        msg =~ message
      end
    end
  end
end