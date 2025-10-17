class CreateAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.references :user

      t.string :line_one, default: ""
      t.string :line_two, default: ""
      t.string :city, default: ""
      t.string :state, default: ""
      t.string :zip, default: ""
      t.string :country, default: ""

      t.timestamps
    end
  end
end
