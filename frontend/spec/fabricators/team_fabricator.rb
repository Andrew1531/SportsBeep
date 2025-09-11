Fabricator(:team) do
  external_id     { SecureRandom.hex }
  abbr            { ('AA'..'ZZ').to_a.sample }
  name            { Faker::Name.name }
  market          { Faker::Address.city }
  league          nil
  division        nil
  primary_color   { '9ab74e' }
  secondary_color { '000000' }
  type            { ENV['SPORT'] && "#{ENV['SPORT']}::Team" }
  players         count: 25
end

Fabricator('Mlb::Team', from: :team) do
  league   { %w(NL AL).sample }
  division { %w(ALC ALE ALW NLC NLE NLW).sample }
  players  count: 25, fabricator: 'Mlb::Player'
  type     'Mlb::Team'
end
