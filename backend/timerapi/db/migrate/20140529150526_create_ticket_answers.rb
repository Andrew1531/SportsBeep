class CreateTicketAnswers < ActiveRecord::Migration
  def change
    create_table :ticket_answers do |t|
      t.integer :ticket_id
      t.integer :question_number
      t.integer :answer
      t.float :answer_time

      t.timestamps
    end
  end
end
