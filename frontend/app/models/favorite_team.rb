class FavoriteTeam < ActiveRecord::Base
  belongs_to :user
  belongs_to :baseball, class_name: 'Mlb::Team'

  validates :user, presence: true

end
