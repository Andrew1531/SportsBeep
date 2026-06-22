class AddBeepLoadedCentsToAccounts < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:accounts, :beep_loaded_cents)
      add_column :accounts, :beep_loaded_cents, :integer, default: 0
    end
  end
end
