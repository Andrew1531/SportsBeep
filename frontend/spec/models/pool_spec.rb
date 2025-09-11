describe Pool do
  describe '#entry_fee' do
    it 'calculates the entry fee based on the multiplier and prize pool' do
      Fabricate(:pool, prize_pool: 5000, entry_fee_multiplier: 1.1).entry_fee.should == 550
      Fabricate(:pool, prize_pool: 2500, entry_fee_multiplier: 1.1).entry_fee.should == 275
      Fabricate(:pool, prize_pool: 50,   entry_fee_multiplier: 1.1).entry_fee.should == 5.5
      Fabricate(:pool, prize_pool: 20,   entry_fee_multiplier: 1.1).entry_fee.should == 2.2
      Fabricate(:pool, prize_pool: 0,    entry_fee_multiplier: 1.1).entry_fee.should == 0
    end
  end
end
