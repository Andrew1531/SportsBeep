# Apple configuration:

APNS.host =
  case Rails.env
  when 'development'
    'gateway.sandbox.push.apple.com'
  else
    'gateway.push.apple.com'
  end

APNS.pem  = ''
APNS.pass = ''

# Android configuration:
# https://code.google.com/apis/console/

GCM.key = ENV['GCM_SERVER_KEY']

