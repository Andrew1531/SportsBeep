class CreateBeepChainTransfers < ActiveRecord::Migration[6.1]
  def change
    create_table :beep_chain_transfers do |t|
      t.references :user, null: false, index: true
      t.string  :direction, null: false            # 'deposit' or 'withdrawal'
      t.integer :amount_beep, null: false
      t.string  :tx_hash
      t.string  :status, null: false, default: 'pending'  # pending / confirmed / credited / failed
      t.string  :error_message
      t.datetime :confirmed_at
      t.timestamps
    end
    add_index :beep_chain_transfers, :tx_hash, unique: true
    add_index :beep_chain_transfers, [:user_id, :status]
  end
end
