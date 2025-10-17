class MakeAccountsForExistingUsers < ActiveRecord::Migration[4.2]
  def up
    if User.any?
      User.all.each do |user|
        user.create_account unless user.account.present?
      end
    end
  end
end
