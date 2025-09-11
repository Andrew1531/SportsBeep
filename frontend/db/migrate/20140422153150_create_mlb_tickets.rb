class CreateMlbTickets < ActiveRecord::Migration
  def change
    create_table :mlb_tickets do |t|
      t.references :contest, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
