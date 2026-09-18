class CreateAdminAuditEventsAndAddUserDisabled < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :disabled, :boolean, null: false, default: false
    add_column :users, :personal_data_removed_at, :datetime
    add_index :users, :disabled

    create_table :admin_audit_events do |t|
      t.references :actor, null: false, foreign_key: { to_table: :administrators }
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.text :changed_fields, null: false
      t.text :reason, null: false
      t.timestamps
    end

    add_index :admin_audit_events, [:user_id, :created_at]
    add_index :admin_audit_events, [:actor_id, :created_at]
  end
end