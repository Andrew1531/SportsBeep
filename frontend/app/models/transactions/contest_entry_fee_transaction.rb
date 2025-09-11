class ContestEntryFeeTransaction < Transaction

  def to_s
    "Contest entry fee for #{user}"
  end

  def commit!
    super do
      GL[:L_GAMER_ACCOUNTS].subtract amount
      GL[:I_CONTEST_FEE_INCOME].add amount
      if account.clearing_expense > 0
        account.update clearing_expense: account.clearing_expense - (amount * CREDIT_CLEARING_EXPENSE_RATE)
      end
    end
  end

  def modify_amount(amount)
    amount * -1
  end

end