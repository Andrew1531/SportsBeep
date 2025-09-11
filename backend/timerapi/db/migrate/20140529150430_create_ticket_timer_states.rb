class CreateTicketTimerStates < ActiveRecord::Migration
  def change
    create_table :ticket_timer_states do |t|
      t.integer :ticket_id
      t.string :state_text
      t.float :state_value

      t.timestamps
    end
  end
end
