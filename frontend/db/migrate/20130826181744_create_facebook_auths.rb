class CreateFacebookAuths < ActiveRecord::Migration[4.2]
  def change
    create_table :facebook_auths do |t|
      t.references :user
      t.string  :uid, null: false
      t.string  :email, null: false
      t.text    :profile_picture
      t.text    :auth_token, null: false

      t.timestamps
    end

    add_index :facebook_auths, :user_id
    add_index :facebook_auths, :uid
    add_index :facebook_auths, :email
    add_index :facebook_auths, [:user_id, :uid], unique: true
  end
end