class AddComparisonToMlbQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :mlb_questions, :comparison, :string
  end
end
