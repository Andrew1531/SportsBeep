class PagesController < ApplicationController

  def how_to_play
  end

  def tos
  end

  def privacy_policy
  end

  def refund_policy
  end

  def reset_request
  end

  def submit_reset_request
    email = params[:email].to_s.strip
    username = params[:username].to_s.strip
    message = params[:message].to_s.strip

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      flash.now[:alert] = 'Please enter the email address on your account.'
      return render :reset_request, status: :unprocessable_entity
    end

    begin
      Web3FormsService.submit(
        subject: 'SportsBeep — Password reset request',
        from_name: 'SportsBeep Support',
        email: email,
        message: <<~MSG
          A user has requested a password reset on SportsBeep.

          Account email: #{email}
          Username: #{username.presence || '(not provided)'}
          Message: #{message.presence || '(none)'}

          Reset their password from the admin panel, then let them know.
        MSG
      )
      redirect_to reset_request_path(sent: 1)
    rescue Web3FormsService::Error => e
      Rails.logger.error "Password reset request failed: #{e.message}"
      flash.now[:alert] = 'We could not send your request right now. Please email support@sportsbeep.com directly.'
      render :reset_request, status: :service_unavailable
    end
  end

end
