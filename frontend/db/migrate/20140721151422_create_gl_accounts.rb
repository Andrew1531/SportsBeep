class CreateGlAccounts < ActiveRecord::Migration
  def change
    create_table :gl_accounts do |t|
      t.string :name
      t.integer :balance, default: 0

      t.timestamps
    end
  end
end
