Fabricator(:player) do
  external_id   { SecureRandom.hex }
  first_name    { Faker::Name.first_name }
  last_name     { Faker::Name.last_name }
  number        { rand(1..99) }
  status        ""
  on_current_roster true
  type { ENV['SPORT'] && "#{ENV['SPORT']}::Player" }

  position do
    case ENV['SPORT']
    when 'Mlb'
      %w(C 1B 2B SS 3B CF RF LF BP).sample
    when 'Nfl'
      %w(RB WR K TE).sample
    end
  end
end

Fabricator('Mlb::Player', from: :player) do
  position { %w(P C 1B 2B SS 3B CF RF LF BP).sample }
  type     'Mlb::Player'
end
