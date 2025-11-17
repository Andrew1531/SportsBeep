class Admin::BaseController < ApplicationController

  before_action :set_current_sport
  before_action :authenticate_administrator!

  layout 'admin'
  respond_to :html
  self.responder = AdminResponder

  def current_user
    current_administrator
  end

  def current_sport
    session[:current_sport] || 'mlb'
  end
  helper_method :current_sport

  def set_current_sport
    # Default to MLB if no sport is set
    session[:current_sport] ||= 'mlb'
  end

end