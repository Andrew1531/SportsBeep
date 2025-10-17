class CreateTicketSquads < ActiveRecord::Migration[4.2]
  def change
    create_table :ticket_squads do |t|
      t.references :ticket, index: true
      t.references :team, index: true
      t.string :position

      t.timestamps
    end
  end
end
