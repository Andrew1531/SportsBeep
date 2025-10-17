class RemoveTopicAndConnotationFromMlbQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :mlb_questions, :comparison
    remove_column :mlb_questions, :connotation
    remove_column :mlb_questions, :topic
  end
end
