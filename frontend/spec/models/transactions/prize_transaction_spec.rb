describe PrizeTransaction do
  let(:user) { Fabricate :user }
  it_behaves_like 'a transaction'

  describe 'GL Account alterations' do
    before { PrizeTransaction.commit(user, 10.50) }

    it 'adds the amount to the E-Prize Expense account' do
      GL[:E_PRIZE_EXPENSE].balance.cents.should == 1050
    end

    it 'adds the amount to the liability account' do
      GL[:L_GAMER_ACCOUNTS].balance.cents.should == 1050
    end

  end
end