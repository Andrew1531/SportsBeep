class MakeAccountsForExistingUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.create_account unless user.account.present?
    end
  end
end
