class DepositTransaction < Transaction

  def to_s
    "User #{user} depositing #{amount} into their account"
  end

  def commit!
    super do
      GL[:A_CASH].add amount * (1 - CREDIT_CLEARING_EXPENSE_RATE)
      GL[:L_GAMER_ACCOUNTS].add amount
      GL[:E_CREDIT_CLEARING_EXPENSE].add amount * CREDIT_CLEARING_EXPENSE_RATE
      account.update clearing_expense: account.clearing_expense + (amount * CREDIT_CLEARING_EXPENSE_RATE)
    end
  end

end