class CreateFavoriteTeams < ActiveRecord::Migration[4.2]
  def change
    create_table :favorite_teams do |t|
      t.references :user, index: true
      t.references :baseball, index: true

      t.timestamps
    end
  end
end
