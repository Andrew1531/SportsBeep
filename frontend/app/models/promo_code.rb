class PromoCode < ActiveRecord::Base
  has_many :users

  validates :code, presence: true, uniqueness: true

end
