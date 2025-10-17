class AddTopicIdToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_reference :mlb_questions, :topic, index: true
  end
end
