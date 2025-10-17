class RemoveOldBestAndBustQuestions < ActiveRecord::Migration[4.2]
  def change
    Mlb::Question.destroy_all
  end
end
