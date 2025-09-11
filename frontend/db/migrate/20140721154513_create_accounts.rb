class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :user, index: true
      t.integer :balance, default: 0

      t.timestamps
    end
  end
end
