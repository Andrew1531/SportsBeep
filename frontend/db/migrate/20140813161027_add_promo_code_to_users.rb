class AddPromoCodeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :promo_code, index: true
  end
end
