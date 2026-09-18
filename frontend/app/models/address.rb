class Address < ActiveRecord::Base
  belongs_to :user

  validates :line_one, :line_two, :city, :state, :zip, :country,
            length: { maximum: 255 }, allow_blank: true
end
