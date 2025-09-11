shared_examples_for 'a transaction' do

  let(:transaction) { subject.class }

  it 'adds the amount to the users balance' do
    before = user.account.balance.cents
    t = transaction.commit(user, 12.34)
    user.account.balance.cents.should ==
      if transaction.in? [ContestEntryFeeTransaction]
        before - 1234
      else
        before + 1234
      end
  end

  it 'stores a new Transaction record' do
    Transaction.count.should == 0
    t = transaction.commit(user, 12.34)
    Transaction.count.should == 1
    Transaction.first.tap do |t|
      t.account.should == user.account
      t.amount.cents.should ==
        if transaction.in? [ContestEntryFeeTransaction]
          -1234
        else
          1234
        end
    end
  end

end