class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :reset_session

  def home
    render :home, layout: 'landing'
  end

  def landing
    render :landing, layout: 'landing'
  end

  def app
    authenticate_user!
  end

end
