class CreateMlbQuestionAnswers < ActiveRecord::Migration
  def change
    create_table :mlb_question_answers do |t|
      t.references :question, index: true
      t.references :answer, index: true
      t.references :ticket, index: true
      t.float :time

      t.timestamps
    end
  end
end
