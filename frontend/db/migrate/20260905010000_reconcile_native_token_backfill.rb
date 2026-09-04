class ReconcileNativeTokenBackfill < ActiveRecord::Migration[6.1]
  def up
    unit, policy = validated_beep_identity!
    token_id = select_value(<<~SQL.squish)
      SELECT id FROM approved_tokens
      WHERE asset_unit = #{connection.quote(unit)}
        AND policy_id = #{connection.quote(policy)}
    SQL
    raise 'The approved BEEP registry entry is missing or does not match its configured policy' unless token_id

    assert_legacy_beep_is_whole_units!

    if connection.adapter_name.downcase.include?('postgres')
      execute <<~SQL.squish
        UPDATE account_token_balances
        SET balance_units = accounts.balance_cents / 100,
            loaded_units = accounts.beep_loaded_cents / 100,
            updated_at = CURRENT_TIMESTAMP
        FROM accounts
        WHERE account_token_balances.account_id = accounts.id
          AND account_token_balances.approved_token_id = #{token_id}
      SQL
    else
      execute <<~SQL.squish
        UPDATE account_token_balances
        SET balance_units = (SELECT balance_cents / 100 FROM accounts WHERE accounts.id = account_token_balances.account_id),
            loaded_units = (SELECT beep_loaded_cents / 100 FROM accounts WHERE accounts.id = account_token_balances.account_id),
            updated_at = CURRENT_TIMESTAMP
        WHERE approved_token_id = #{token_id}
      SQL
    end

    execute <<~SQL.squish
      INSERT INTO account_token_balances (account_id, approved_token_id, balance_units, loaded_units, created_at, updated_at)
      SELECT id, #{token_id}, balance_cents / 100, beep_loaded_cents / 100, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM accounts
      WHERE NOT EXISTS (
        SELECT 1 FROM account_token_balances balances
        WHERE balances.account_id = accounts.id AND balances.approved_token_id = #{token_id}
      )
    SQL
    execute "UPDATE transactions SET approved_token_id = #{token_id}, amount_units = amount_cents / 100 WHERE approved_token_id IS NULL"
    execute "UPDATE wagers SET approved_token_id = #{token_id}, amount_units = amount_cents / 100, potential_payout_units = potential_payout_cents / 100 WHERE approved_token_id IS NULL"
    execute "UPDATE tickets SET approved_token_id = #{token_id}, entry_fee_units = COALESCE(entry_fee_units, 0) WHERE approved_token_id IS NULL"
    execute "UPDATE beep_chain_transfers SET approved_token_id = #{token_id}, amount_units = amount_beep WHERE approved_token_id IS NULL"
  end

  def down
    # Data reconciliation is intentionally irreversible.
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