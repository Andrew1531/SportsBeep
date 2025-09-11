describe CommissionTransaction do
  let(:user) { Fabricate :user }
  it_behaves_like 'a transaction'

  describe 'GL Account alterations' do
    before { CommissionTransaction.commit(user, 10.50) }

    it 'adds the amount to the E-Commission Expense account' do
      GL[:E_COMMISSION_EXPENSE].balance.cents.should == 1050
    end

    it 'adds the amount to the L-Gamer Accounts account' do
      GL[:E_COMMISSION_EXPENSE].balance.cents.should == 1050
    end
  end

end