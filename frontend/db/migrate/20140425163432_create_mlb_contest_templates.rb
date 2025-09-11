class CreateMlbContestTemplates < ActiveRecord::Migration
  def change
    create_table :mlb_contest_templates do |t|
      t.references :game, index: true
      t.references :pool, index: true
      t.integer :max_contests

      t.timestamps
    end
  end
end
