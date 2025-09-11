describe DepositTransaction do
  let!(:user) { Fabricate :user }
  it_behaves_like 'a transaction'

  describe 'GL Account alterations' do
    before { DepositTransaction.commit(user, 100.25) }

    it 'adds the amount subtracted by the CC expense to the cash account' do
      GL[:A_CASH].balance.cents.should == 9824
    end

    it 'adds the amount to the liability gamer account' do
      GL[:L_GAMER_ACCOUNTS].balance.cents.should == 10025
    end

    it 'adds the amount multiplied by the CC expense to the E-Credit Clearing Expense account' do
      GL[:E_CREDIT_CLEARING_EXPENSE].balance.cents.should == 200
    end

    it 'stores the clearing expense on the user account' do
      user.account.clearing_expense.cents.should == 200
    end

  end
end