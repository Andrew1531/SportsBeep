class CreateMlbTimerStates < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_timer_states do |t|
      t.references :ticket, index: true
      t.string :encrypted_text
      t.float :value

      t.timestamps
    end
  end
end
