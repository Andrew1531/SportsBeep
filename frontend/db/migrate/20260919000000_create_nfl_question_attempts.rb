class CreateNflQuestionAttempts < ActiveRecord::Migration[6.1]
  def change
    create_table :nfl_question_attempts do |t|
      t.references :ticket, null: false, foreign_key: true, type: :integer
      t.references :question, null: false, foreign_key: true, type: :integer
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.timestamps
    end

    add_index :nfl_question_attempts, [:ticket_id, :question_id],
              unique: true, name: 'index_nfl_question_attempts_unique'
  end
end