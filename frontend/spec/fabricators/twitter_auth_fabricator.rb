Fabricator(:twitter_auth) do
  user { Fabricate(:user) }
  uid { Faker::Number.number(10) }
  username { Faker::Internet.user_name }
  auth_token { Base64.encode64(Faker::Lorem.sentence).gsub(/\n/, '') }
  auth_secret { Base64.encode64(Faker::Lorem.sentence).gsub(/\n/, '') }
end
