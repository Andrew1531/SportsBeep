class CreateAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :accounts do |t|
      t.references :user, index: true
      t.integer :balance, default: 0

      t.timestamps
    end
  end
end
