describe BeepWithdrawalConfirmationService do
  let(:blockfrost) { double('BlockfrostService') }
  let(:service) { described_class.new(blockfrost: blockfrost) }
  let(:user) { Fabricate(:user) }
  let(:account) { user.account }
  let(:tx_hash) { 'b' * 64 }
  let(:transfer) do
    BeepChainTransfer.create!(
      user: user,
      direction: 'withdrawal',
      amount_beep: 2,
      tx_hash: tx_hash,
      status: 'submitted',
      request_key: SecureRandom.uuid,
      destination_address: 'addr1destination'
    )
  end

  it 'marks a verified payout confirmed without changing the debited balance' do
    account.update!(balance_cents: 300)
    blockfrost.stub(:tx_confirmations).with(tx_hash).and_return(2)
    blockfrost.stub(:get_tx_utxos).with(tx_hash).and_return(
      'outputs' => [
        {
          'address' => 'addr1destination',
          'amount' => [{ 'unit' => 'beep-unit', 'quantity' => '2' }]
        }
      ]
    )
    blockfrost.stub(:beep_unit?).with('beep-unit').and_return(true)

    service.call(transfer).should == 'confirmed'
    account.reload.balance_cents.should == 300
  end

  it 'refunds an expired absent payout exactly once' do
    account.update!(balance_cents: 300)
    transfer.update_column(:created_at, 3.hours.ago)
    blockfrost.stub(:tx_confirmations).with(tx_hash).and_return(nil)

    service.call(transfer).should == 'failed'
    service.call(transfer).should == 'failed'

    account.reload.balance_cents.should == 500
    account.transactions.where('description LIKE ?', 'Refund: on-chain withdrawal%').count.should == 1
  end

  it 'fails a stale unsubmitted request without changing the balance' do
    transfer.update_columns(status: 'pending', tx_hash: nil, created_at: 11.minutes.ago)

    service.call(transfer).should == 'failed'
    account.reload.balance_cents.should == 0
  end
end