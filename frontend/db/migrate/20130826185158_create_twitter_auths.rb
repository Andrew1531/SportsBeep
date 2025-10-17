class CreateTwitterAuths < ActiveRecord::Migration[4.2]
  def change
    create_table :twitter_auths do |t|
      t.references :user
      t.string  :uid, null: false
      t.string  :username, null: false
      t.text    :auth_token, null: false
      t.text    :auth_secret, null: false

      t.timestamps
    end

    add_index :twitter_auths, :user_id
    add_index :twitter_auths, :uid
    add_index :twitter_auths, :username
    add_index :twitter_auths, [:user_id, :uid], unique: true
  end
end
