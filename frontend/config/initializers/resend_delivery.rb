# Registers :resend as an ActionMailer delivery method so all app mail
# (including Devise password reset emails) is sent through the Replit Resend
# connector. Failures raise and are logged by ResendService — no silent drops.
class ResendDeliveryMethod
  attr_accessor :settings

  def initialize(settings = {})
    @settings = settings
  end

  def deliver!(mail)
    html = mail.html_part&.body&.decoded
    text = mail.text_part&.body&.decoded

    if html.nil? && text.nil?
      body = mail.body.decoded
      if mail.content_type.to_s.include?('text/html')
        html = body
      else
        text = body
      end
    end

    # The From header on the mail object (e.g. Devise's mailer_sender) is
    # intentionally overridden by ResendService.from_address, because Resend
    # only accepts senders from verified domains (or its test sender).
    ResendService.send_email(
      to: mail.to,
      subject: mail.subject,
      html: html,
      text: text
    )
  end
end

ActionMailer::Base.add_delivery_method :resend, ResendDeliveryMethod
