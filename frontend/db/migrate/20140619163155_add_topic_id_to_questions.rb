class AddTopicIdToQuestions < ActiveRecord::Migration
  def change
    add_reference :mlb_questions, :topic, index: true
  end
end
