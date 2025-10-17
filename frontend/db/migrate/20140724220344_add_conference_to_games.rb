class AddConferenceToGames < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :conference, :string
  end
end
