Fabricator(:gl_account) do
  name   { Faker::Company.name }
  balance { rand(1..100_000) }
end
