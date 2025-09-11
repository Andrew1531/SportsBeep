Fabricator(:transaction) do
  user
  amount      100.25
  description "MyString"
  status      "MyString"
  type        "DepositTransaction"
end
