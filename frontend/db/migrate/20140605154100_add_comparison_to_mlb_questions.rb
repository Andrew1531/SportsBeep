class AddComparisonToMlbQuestions < ActiveRecord::Migration
  def change
    add_column :mlb_questions, :comparison, :string
  end
end
