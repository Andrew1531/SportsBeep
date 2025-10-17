class CreatePromoCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.string :note
      t.integer :users_count, default: 0

      t.timestamps
    end
  end
end
