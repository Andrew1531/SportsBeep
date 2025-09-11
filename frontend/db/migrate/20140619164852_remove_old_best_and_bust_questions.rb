class RemoveOldBestAndBustQuestions < ActiveRecord::Migration
  def change
    Mlb::Question.destroy_all
  end
end
