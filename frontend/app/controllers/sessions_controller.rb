class SessionsController < Devise::SessionsController

  def after_sign_in_path_for(*)
    play_path
  end

end