describe PromoReleaseTransaction do
  let(:user) { Fabricate :user }
  it_behaves_like 'a transaction'

  describe 'GL Account alterations' do
    before do
      user.account.update promo_balance: Money.new(10000)
      PromoReleaseTransaction.commit(user, 10.50)
    end

    it 'adds the amount to the game liability account' do
      GL[:L_GAMER_ACCOUNTS].balance.cents.should == 1050
    end

    it 'adds the amount to the E-Promo released account' do
      GL[:E_PROMO_RELEASED].balance.cents.should == 1050
    end

    it 'subtracts the amount from the users promo balance' do
      user.reload.account.promo_balance.cents.should == 8950
    end

  end
end