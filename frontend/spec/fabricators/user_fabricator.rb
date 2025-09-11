Fabricator(:user) do
  first_name   { Faker::Name.first_name }
  last_name    { Faker::Name.last_name }
  email        { Faker::Internet.email }
  username     { sequence(:username) { |i| "user-#{SecureRandom.hex}" } }
  password     'password'
  device_token { SecureRandom.hex }
  platform     'android'
  avatar_processing false
end
