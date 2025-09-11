describe ContestEntryFeeTransaction do
  let(:user) { Fabricate :user }
  it_behaves_like 'a transaction'

  describe 'GL Account alterations' do
    before { ContestEntryFeeTransaction.commit(user, 10.50) }

    it 'subtracts the amount from the L Gamer Accounts account' do
      GL[:L_GAMER_ACCOUNTS].balance.cents.should == -1050
    end

    it 'adds the account to the I-Contest Fee Income account' do
      GL[:I_CONTEST_FEE_INCOME].balance.cents.should == 1050
    end
  end

  it 'subtracts the amount * credit clearing expense rate if there is any clearing expense' do
    user.account.update clearing_expense: Money.new(10000)
    ContestEntryFeeTransaction.commit(user, 10.50)
    user.account.reload.clearing_expense.cents.should == 9979
  end

  it 'does not subtract the amount * credit clearing expense rate if the clearing expense is 0 already' do
    user.account.update clearing_expense: Money.new(0)
    ContestEntryFeeTransaction.commit(user, 10.50)
    user.account.reload.clearing_expense.cents.should == 0
  end

end