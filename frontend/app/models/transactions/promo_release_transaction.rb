class PromoReleaseTransaction < Transaction

  def to_s
    "Promo release"
  end

  def commit!
    super do
      GL[:L_GAMER_ACCOUNTS].add amount
      GL[:E_PROMO_RELEASED].add amount
      account.update promo_balance: (account.promo_balance - amount)
    end
  end

end