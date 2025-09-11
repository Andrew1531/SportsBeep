class CreateFavoriteTeams < ActiveRecord::Migration
  def change
    create_table :favorite_teams do |t|
      t.references :user, index: true
      t.references :baseball, index: true

      t.timestamps
    end
  end
end
