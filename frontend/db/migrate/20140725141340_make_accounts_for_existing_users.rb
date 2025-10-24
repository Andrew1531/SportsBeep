class MakeAccountsForExistingUsers < ActiveRecord::Migration[4.2]
  def up
    if table_exists?(:users) && User.count > 0
      User.all.each do |user|
        user.create_account unless user.account.present?
      end
    end
  end
end
