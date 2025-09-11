describe AdjustmentTransaction do
  let(:user) { Fabricate :user }
  it_behaves_like 'a transaction'

  it 'adds the amount to the game liability account' do
    AdjustmentTransaction.commit(user, 346.23)
    GL[:L_GAMER_ACCOUNTS].balance.cents.should == 34623
  end

end