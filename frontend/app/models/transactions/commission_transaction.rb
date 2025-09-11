class CommissionTransaction < Transaction

  def to_s
    "Commission"
  end

  def commit!
    super do
      GL[:E_COMMISSION_EXPENSE].add amount
      GL[:L_GAMER_ACCOUNTS].add amount
    end
  end

end