class CreateCardanoSwaps < ActiveRecord::Migration[6.1]
  def change
    create_table :swap_assets do |t|
      t.string :asset_unit, null: false
      t.string :policy_id
      t.string :ticker, null: false
      t.integer :decimals, null: false, default: 0
      t.decimal :beep_per_asset, precision: 30, scale: 12, null: false
      t.boolean :enabled, null: false, default: true
      t.timestamps
    end
    add_index :swap_assets, :asset_unit, unique: true

    create_table :swap_quotes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :swap_asset, null: false, foreign_key: true
      t.bigint :amount_units, null: false
      t.bigint :beep_amount, null: false
      t.decimal :beep_per_asset, precision: 30, scale: 12, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end

    create_table :cardano_swaps do |t|
      t.references :user, null: false, foreign_key: true
      t.references :swap_asset, null: false, foreign_key: true
      t.references :swap_quote, null: false, foreign_key: true, index: { unique: true }
      t.bigint :amount_units, null: false
      t.bigint :beep_amount, null: false
      t.string :payout_method, null: false
      t.string :source_tx_hash, null: false
      t.string :payout_tx_hash
      t.string :status, null: false, default: 'pending'
      t.string :error_message
      t.datetime :confirmed_at
      t.timestamps
    end
    add_index :cardano_swaps, :source_tx_hash, unique: true
    add_index :cardano_swaps, :payout_tx_hash, unique: true
  end
end