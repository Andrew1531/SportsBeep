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
    # Honeypot: hidden field real users never fill in. Bots that do are
    # silently shown the confirmation page without sending anything.
    return redirect_to reset_request_path(sent: 1) if params[:website].present?

    # Basic per-session throttle to keep the support inbox usable.
    last = session[:reset_request_at].to_i
    if last > 0 && Time.now.to_i - last < 60
      flash.now[:alert] = 'Please wait a minute before sending another request.'
      return render :reset_request, status: :too_many_requests
    end

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
      session[:reset_request_at] = Time.now.to_i
      redirect_to reset_request_path(sent: 1)
    rescue Web3FormsService::Error => e
      Rails.logger.error "Password reset request failed: #{e.message}"
      flash.now[:alert] = 'We could not send your request right now. Please email support@sportsbeep.com directly.'
      render :reset_request, status: :service_unavailable
    end
  end

end
