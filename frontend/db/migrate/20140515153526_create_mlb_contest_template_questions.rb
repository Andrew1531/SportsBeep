class CreateMlbContestTemplateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :mlb_contest_template_questions do |t|
      t.references :contest_template, index: true
      t.references :question, index: true

      t.timestamps
    end
  end
end
