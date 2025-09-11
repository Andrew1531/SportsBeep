describe EnterContest, sport: 'Mlb' do

  let(:ticket) { Fabricate.build :ticket, user: user }
  let(:user) { Fabricate :user }

  it 'charges an entry fee' do
    user.account.update balance: 100.0
    ticket.save
    ContestEntryFeeTransaction.count.should == 1
    user.account.reload.balance.dollars.should be < 100.0
  end

  it 'rolls back the fee if the ticket is invalid' do
    user.account.update balance: 100.0
    expect(ticket).to receive(:valid?) { false }
    ticket.save
    ContestEntryFeeTransaction.count.should == 0
    user.account.reload.balance.dollars.should == 100.0
  end

end