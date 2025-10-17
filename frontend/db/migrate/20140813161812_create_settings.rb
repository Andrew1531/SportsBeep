class CreateSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :settings do |t|
      t.boolean :require_promo_code_on_signup, null: false, default: false

      t.timestamps
    end
  end
end
