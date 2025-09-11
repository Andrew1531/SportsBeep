Fabricator(:facebook_auth) do
  user { Fabricate(:user) }
  uid { Faker::Number.number(10) }
  email { Faker::Internet.email }
  auth_token { Base64.encode64(Faker::Lorem.sentence).gsub(/\n/, '') }
end
