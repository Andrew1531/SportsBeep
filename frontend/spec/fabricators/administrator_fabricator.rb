Fabricator(:administrator) do
  email    { Faker::Internet.email }
  password { SecureRandom.hex }

  after_build do |admin|
    admin.password_confirmation = admin.password
  end

end