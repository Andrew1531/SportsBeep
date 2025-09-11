class PrizeTransaction < Transaction

  def to_s
    "Prize transaction"
  end

  def commit!
    super do
      GL[:E_PRIZE_EXPENSE].add amount
      GL[:L_GAMER_ACCOUNTS].add amount
    end
  end

end