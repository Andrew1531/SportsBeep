class AddPromoCodeToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :promo_code, index: true
  end
end
