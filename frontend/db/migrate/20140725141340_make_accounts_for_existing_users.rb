class MakeAccountsForExistingUsers < ActiveRecord::Migration[4.2]
  def up
    # Skip - accounts will be created automatically by application logic when users sign in
    # This migration was for migrating existing legacy data, not needed for fresh databases
  end
end
