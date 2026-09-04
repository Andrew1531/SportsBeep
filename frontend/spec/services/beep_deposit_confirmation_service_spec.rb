describe BeepDepositConfirmationService do
  let(:blockfrost) { double('BlockfrostService') }
  let(:service) { described_class.new(blockfrost: blockfrost) }
  let(:user) { Fabricate(:user) }
  let(:account) { user.account }
  let(:tx_hash) { 'a' * 64 }
  let(:transfer) do
    BeepChainTransfer.create!(
      user: user,
      direction: 'deposit',
      amount_beep: 7,
      tx_hash: tx_hash,
      status: 'pending'
    )
  end

  around do |example|
    old_treasury = ENV['TREASURY_ADDRESS']
    ENV['TREASURY_ADDRESS'] = 'addr1treasury'
    example.run
  ensure
    ENV['TREASURY_ADDRESS'] = old_treasury
  end

  it 'credits a confirmed treasury deposit exactly once' do
    blockfrost.stub(:tx_confirmations).with(tx_hash).and_return(2)
    blockfrost.stub(:get_tx_utxos).with(tx_hash).and_return(
      'inputs' => [{ 'address' => 'addr1user' }],
      'outputs' => [
        {
          'address' => 'addr1treasury',
          'amount' => [{ 'unit' => 'beep-unit', 'quantity' => '7' }]
        }
      ]
    )
    blockfrost.stub(:beep_unit?).with('beep-unit').and_return(true)
    CardanoAddress.stub(:same_wallet?).and_return(true)

    service.call(transfer).should == 'credited'
    service.call(transfer).should == 'credited'

    account.reload.balance_cents.should == 700
    account.transactions.where('description LIKE ?', 'On-chain deposit%').count.should == 1
  end

  it 'fails a confirmed transaction that did not fund the treasury enough' do
    blockfrost.stub(:tx_confirmations).with(tx_hash).and_return(2)
    blockfrost.stub(:get_tx_utxos).with(tx_hash).and_return(
      'inputs' => [{ 'address' => 'addr1user' }],
      'outputs' => [
        {
          'address' => 'addr1treasury',
          'amount' => [{ 'unit' => 'beep-unit', 'quantity' => '6' }]
        }
      ]
    )
    blockfrost.stub(:beep_unit?).with('beep-unit').and_return(true)
    CardanoAddress.stub(:same_wallet?).and_return(true)

    service.call(transfer).should == 'failed'
    account.reload.balance_cents.should == 0
  end

  it 'expires a deposit that never appears on-chain' do
    transfer.update_column(:created_at, 3.hours.ago)
    blockfrost.stub(:tx_confirmations).with(tx_hash).and_return(nil)

    service.call(transfer).should == 'failed'
    transfer.reload.error_message.should include('not found on-chain')
    account.reload.balance_cents.should == 0
  end
end