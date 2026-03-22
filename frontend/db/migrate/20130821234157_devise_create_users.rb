class DeviseCreateUsers < ActiveRecord::Migration[4.2]
  def up
    unless table_exists?(:users)
      create_table(:users) do |t|
        t.string :first_name
        t.string :last_name
        t.string :full_name
        t.string :email, null: false, default: "", unique: true
        t.date :date_of_birth
        t.string :gender
        t.boolean :private, default: false
        t.string :avatar
        t.string :encrypted_password, null: false, default: ""
        t.string   :reset_password_token
        t.datetime :reset_password_sent_at
        t.datetime :remember_created_at
        t.integer  :sign_in_count, default: 0
        t.datetime :current_sign_in_at
        t.datetime :last_sign_in_at
        t.string   :current_sign_in_ip
        t.string   :last_sign_in_ip
        t.string   :confirmation_token
        t.datetime :confirmed_at
        t.datetime :confirmation_sent_at
        t.string   :unconfirmed_email
        t.string :authentication_token
        t.datetime :destroyed_at
        t.timestamps
      end
    end

    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    add_index :users, :confirmation_token, unique: true unless index_exists?(:users, :confirmation_token)
    add_index :users, :authentication_token unless index_exists?(:users, :authentication_token)
  end

  def down
    drop_table :users
  end
end
