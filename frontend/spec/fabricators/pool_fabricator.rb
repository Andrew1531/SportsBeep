Fabricator(:pool) do
  prize_pool              { rand(1..50) }
  max_tickets_per_contest 10
  max_contests            100
  entry_fee_multiplier    1.1
  default                 false
end
