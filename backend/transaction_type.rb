class TransactionType
  Deposit = 0
  Withdrawal = 1
  ContestEntryFee = 2
  Prize = 3
  Commission = 4
  PromoRelease = 5
  Adjustment = 6
  Other = 7

  def self.to_s(type)
    case type
      when 0
        'Deposit'
      when 1
        'Withdrawal'
      when 2
        'Contest Entry Fee'
      when 3
        'Prize'
      when 4
        'Commission'
      when 5
        'Promo Release'
      when 6
        'Adjustment'
      else
      'Other'
    end
  end
end
