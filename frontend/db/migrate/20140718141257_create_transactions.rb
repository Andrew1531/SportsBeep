class CreateTransactions < ActiveRecord::Migration[4.2]
  def change
    create_table :transactions do |t|
      t.references :contest, index: true
      t.string :amount
      t.string :description
      t.string :status
      t.string :type

      t.timestamps
    end
  end
end
