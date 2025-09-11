class WithdrawalTransaction < Transaction

  def to_s
    "Withdrawal transaction"
  end

  def commit!
    super do
      @adjusted_amount = amount
      fee = determine_early_withdrawal_fee(amount) if account.clearing_expense > 0
      if fee && fee > 0
        charge_early_withdrawal_fee(fee)
        @adjusted_amount -= fee
      end
      GL[:A_CASH].subtract @adjusted_amount
      GL[:L_GAMER_ACCOUNTS].subtract @adjusted_amount
      self.amount = @adjusted_amount
    end
  end

  def modify_amount(amount)
    @adjusted_amount - amount
  end

  private

    def determine_early_withdrawal_fee(amount)
      [account.clearing_expense, amount * CREDIT_CLEARING_EXPENSE_RATE].min
    end

    def charge_early_withdrawal_fee(fee)
      account.subtract_from_clearing_expense!(fee)
      transaction = AdjustmentTransaction.create! account: account, amount: (fee * -1), description: "Early withdrawal fee of #{fee}."
      GL[:E_CREDIT_CLEARING_EXPENSE].subtract fee
      GL[:E_CREDIT_CLEARING_EXPENSE_R].add fee
      GL[:E_CREDIT_CLEARING_RECOUP_EW].add fee
    end

end