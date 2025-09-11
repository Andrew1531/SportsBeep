describe GlAccount do

  describe '.[]' do
    it 'returns the GL account with the name given' do
      acct = Fabricate :gl_account, name: 'TEST_123'
      GL[:TEST_123].should == acct
    end
  end

  describe '#add' do
    it 'adds the money as cents to the amount field' do
      acct = Fabricate :gl_account, balance: Money.new(12345)
      acct.add Money.new(1595)
      acct.reload.balance.cents.should == 13940
    end
  end

end
