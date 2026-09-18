# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password, :admin_password, :reason, :removal_confirmation,
  :email, :username, :first_name, :last_name,
  :line_one, :line_two, :city, :state, :zip, :country
]
