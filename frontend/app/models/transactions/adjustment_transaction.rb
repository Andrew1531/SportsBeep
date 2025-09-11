class AdjustmentTransaction < Transaction

  def to_s
    "Adjustment"
  end

  def commit!
    super do
      GL[:L_GAMER_ACCOUNTS].add amount
    end
  end

end