class AddConferenceToGames < ActiveRecord::Migration
  def change
    add_column :teams, :conference, :string
  end
end
