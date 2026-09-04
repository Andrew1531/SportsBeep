require 'test_helper'

class CardanoSwapConfirmationServiceTest < ActiveSupport::TestCase
  FakeBlockfrost = Struct.new(:confirmations, :utxos, :lovelace, :beep) do
    def tx_confirmations(_); confirmations; end
    def get_tx_utxos(_); utxos; end
    def get_lovelace_balance(_); lovelace; end
    def get_token_balance(_, _); beep; end
  end

  setup do
    @old_treasury, @old_beep = ENV['TREASURY_ADDRESS'], ENV['BEEP_ASSET_UNIT']
    ENV['TREASURY_ADDRESS'] = 'addr1treasury'
    ENV['BEEP_ASSET_UNIT'] = ('b' * 56) + '42454550'
    @user = User.create!(email: "swap-#{SecureRandom.hex(4)}@example.com", password: 'Password123!', password_confirmation: 'Password123!', username: "swap#{SecureRandom.hex(3)}", first_name: 'Swap', last_name: 'User', cardano_wallet_address: 'addr1user', cardano_wallet_verified_at: Time.current)
    @beep = ApprovedToken.create!(policy_id: 'b' * 56, asset_unit: ENV['BEEP_ASSET_UNIT'], display_name: 'BEEP', ticker: "BP#{SecureRandom.hex(2)}", decimals: 0)
    @asset = SwapAsset.create!(asset_unit: 'lovelace', ticker: 'ADA', decimals: 6, beep_per_asset: 5)
    @quote = @user.swap_quotes.create!(swap_asset: @asset, amount_units: 1_000_000, beep_amount: 5, beep_per_asset: 5, expires_at: 5.minutes.from_now)
    @swap = @user.cardano_swaps.create!(swap_quote: @quote, swap_asset: @asset, amount_units: 1_000_000, beep_amount: 5, payout_method: 'game_balance', source_tx_hash: 'a' * 64)
    @blockfrost = FakeBlockfrost.new
  end

  teardown do
    ENV['TREASURY_ADDRESS'], ENV['BEEP_ASSET_UNIT'] = @old_treasury, @old_beep
  end

  test 'waits for two confirmations' do
    @blockfrost.confirmations = 1
    assert_equal 'pending', CardanoSwapConfirmationService.new(blockfrost: @blockfrost).call(@swap)
  end

  test 'requires exact ADA amount and verified sender' do
    @blockfrost.confirmations = 2
    @blockfrost.utxos = { 'inputs' => [{ 'address' => 'addr1other' }], 'outputs' => [{ 'address' => 'addr1treasury', 'amount' => [{ 'unit' => 'lovelace', 'quantity' => '1000000' }] }] }
    with_singleton_method(CardanoAddress, :same_wallet?, proc { |_, _| false }) do
      assert_equal 'failed', CardanoSwapConfirmationService.new(blockfrost: @blockfrost).call(@swap)
    end
  end

  test 'credits game BEEP exactly once after exact confirmed input' do
    @blockfrost.confirmations = 2
    @blockfrost.utxos = tx_data
    with_singleton_method(CardanoAddress, :same_wallet?, proc { |_, _| true }) do
      service = CardanoSwapConfirmationService.new(blockfrost: @blockfrost)
      assert_equal 'credited', service.call(@swap)
      assert_equal 'credited', service.call(@swap.reload)
    end
    assert_equal 5, @user.account.token_balance_for(@beep).reload.balance_units
    assert_equal 1, @user.account.transactions.where("description LIKE 'Swap credit:%'").count
  end

  test 'does not retry an ambiguously submitted wallet payout' do
    quote = @user.swap_quotes.create!(swap_asset: @asset, amount_units: 1_000_000, beep_amount: 5, beep_per_asset: 5, expires_at: 5.minutes.from_now)
    swap = @user.cardano_swaps.create!(swap_quote: quote, swap_asset: @asset, amount_units: 1_000_000, beep_amount: 5, payout_method: 'wallet', source_tx_hash: 'c' * 64)
    @blockfrost.confirmations = 2
    @blockfrost.utxos = tx_data
    @blockfrost.lovelace = CardanoTxTool::MIN_PAYOUT_LOVELACE
    @blockfrost.beep = 5
    error = CardanoTxTool::Error.new('network timeout', stage: 'submit', tx_hash: 'd' * 64)
    with_singleton_method(CardanoAddress, :same_wallet?, proc { |_, _| true }) do
      with_singleton_method(CardanoTxTool, :with_payout_lock, proc { |&b| b.call }) do
        with_singleton_method(CardanoTxTool, :build_payout, proc { |**_| { signed_tx: 'signed', tx_hash: 'd' * 64 } }) do
          with_singleton_method(CardanoTxTool, :submit_payout, proc { |_tx| raise error }) do
            assert_equal 'unknown', CardanoSwapConfirmationService.new(blockfrost: @blockfrost).call(swap)
          end
        end
      end
    end
    assert_equal 'unknown', swap.reload.status
    refute CardanoSwap.pollable.where(id: swap.id).exists?
  end

  private
  def with_singleton_method(object, name, replacement)
    original = object.method(name)
    object.define_singleton_method(name, &replacement)
    yield
  ensure
    object.define_singleton_method(name) { |*args, **kwargs, &block| original.call(*args, **kwargs, &block) }
  end

  def tx_data
    { 'inputs' => [{ 'address' => 'addr1user' }], 'outputs' => [{ 'address' => 'addr1treasury', 'amount' => [{ 'unit' => 'lovelace', 'quantity' => '1000000' }] }] }
  end
end