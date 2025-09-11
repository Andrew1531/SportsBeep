class Mlb::Season < ActiveRecord::Base
  has_many :games

  self.inheritance_column = nil

end
