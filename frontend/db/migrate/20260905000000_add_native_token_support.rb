class AddNativeTokenSupport < ActiveRecord::Migration[6.1]
  def up
    change_column :beep_chain_transfers, :amount_beep, :bigint
    create_table :approved_tokens do |t|
      t.string :asset_unit, null: false
      t.string :policy_id, null: false
      t.string :display_name, null: false
      t.string :ticker, null: false
      t.integer :decimals, null: false, default: 0
      t.boolean :enabled, null: false, default: true
      t.timestamps
    end
    add_index :approved_tokens, :asset_unit, unique: true
    add_index :approved_tokens, :ticker, unique: true

    create_table :account_token_balances do |t|
      t.references :account, null: false, foreign_key: true
      t.references :approved_token, null: false, foreign_key: true
      t.bigint :balance_units, null: false, default: 0
      t.bigint :loaded_units, null: false, default: 0
      t.timestamps
    end
    add_index :account_token_balances, [:account_id, :approved_token_id], unique: true, name: 'index_token_balances_on_account_and_token'

    add_reference :transactions, :approved_token, foreign_key: true
    add_column :transactions, :amount_units, :bigint
    add_reference :wagers, :approved_token, foreign_key: true
    add_column :wagers, :amount_units, :bigint
    add_column :wagers, :potential_payout_units, :bigint
    add_reference :tickets, :approved_token, foreign_key: true
    add_column :tickets, :entry_fee_units, :bigint
    add_reference :beep_chain_transfers, :approved_token, foreign_key: true
    add_column :beep_chain_transfers, :amount_units, :bigint

    unit, policy = validated_beep_identity!
    assert_legacy_beep_is_whole_units!

    execute <<~SQL.squish
      INSERT INTO approved_tokens (asset_unit, policy_id, display_name, ticker, decimals, enabled, created_at, updated_at)
      VALUES (#{connection.quote(unit)}, #{connection.quote(policy)}, 'SportsBeep', 'BEEP', 0, #{connection.quoted_true}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL
    token_id = select_value("SELECT id FROM approved_tokens WHERE asset_unit = #{connection.quote(unit)}")
    execute <<~SQL.squish
      INSERT INTO account_token_balances (account_id, approved_token_id, balance_units, loaded_units, created_at, updated_at)
      SELECT id, #{token_id}, balance_cents / 100, beep_loaded_cents / 100, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM accounts
    SQL
    execute "UPDATE transactions SET approved_token_id = #{token_id}, amount_units = amount_cents / 100"
    execute "UPDATE wagers SET approved_token_id = #{token_id}, amount_units = amount_cents / 100, potential_payout_units = potential_payout_cents / 100"
    execute "UPDATE tickets SET approved_token_id = #{token_id}, entry_fee_units = 0"
    execute "UPDATE beep_chain_transfers SET approved_token_id = #{token_id}, amount_units = amount_beep"
  end

  def down
    change_column :beep_chain_transfers, :amount_beep, :integer
    remove_column :beep_chain_transfers, :amount_units
    remove_reference :beep_chain_transfers, :approved_token
    remove_column :tickets, :entry_fee_units
    remove_reference :tickets, :approved_token
    remove_column :wagers, :potential_payout_units
    remove_column :wagers, :amount_units
    remove_reference :wagers, :approved_token
    remove_column :transactions, :amount_units
    remove_reference :transactions, :approved_token
    drop_table :account_token_balances
    drop_table :approved_tokens
  end

  private

  def validated_beep_identity!
    unit = ENV['BEEP_ASSET_UNIT'].to_s.strip.downcase
    policy = ENV['BEEP_POLICY_ID'].to_s.strip.downcase
    unless unit.match?(/\A[0-9a-f]{56}(?:[0-9a-f]{2}){0,32}\z/) &&
           policy.match?(/\A[0-9a-f]{56}\z/) &&
           unit.start_with?(policy)
      raise 'BEEP_ASSET_UNIT and BEEP_POLICY_ID must identify the same exact Cardano asset before migrating balances'
    end
    [unit, policy]
  end

  def assert_legacy_beep_is_whole_units!
    checks = {
      accounts: 'balance_cents % 100 != 0 OR beep_loaded_cents % 100 != 0',
      transactions: 'amount_cents % 100 != 0',
      wagers: 'amount_cents % 100 != 0 OR potential_payout_cents % 100 != 0'
    }
    incompatible = checks.select { |table, condition| select_value("SELECT COUNT(*) FROM #{table} WHERE #{condition}").to_i.positive? }
    return if incompatible.empty?

    raise "Cannot migrate fractional legacy BEEP values without losing smallest units (#{incompatible.keys.join(', ')})"
  end
end