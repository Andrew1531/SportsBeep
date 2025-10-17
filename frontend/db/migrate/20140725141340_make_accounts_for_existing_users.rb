class MakeAccountsForExistingUsers < ActiveRecord::Migration[4.2]
  def up
    User.all.each do |user|
      user.create_account unless user.account.present?
    end
  end
end
