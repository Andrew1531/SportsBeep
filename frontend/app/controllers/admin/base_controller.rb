class Admin::BaseController < ApplicationController

  before_action :set_current_sport
  before_action :authenticate_administrator!

  layout 'admin'
  respond_to :html
  self.responder = AdminResponder

  include Pundit

  def current_user
    current_administrator
  end

  def current_sport
    session[:current_sport] || 'mlb'
  end
  helper_method :current_sport

  rescue_from(Pundit::NotAuthorizedError) do |e|
    flash[:danger] = 'Not authorized to do that'
    redirect_to :back
  end

  def set_current_sport
    session[:current_sport] = _sport.name.downcase if _sport
  end

end