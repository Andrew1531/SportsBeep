class CreateMlbQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_questions do |t|
      t.string :type
      t.string :topic
      t.string :connotation
      t.string :text

      t.timestamps
    end
  end
end
