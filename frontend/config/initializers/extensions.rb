# Require core extensions from lib/exti *Cannot be autoloaded
Dir[Rails.root.join('lib', 'ext', '*.rb')].each { |f| require f }