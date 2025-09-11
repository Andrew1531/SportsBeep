class SeasonalStat < ActiveRecord::Base
  belongs_to :player, touch: true

  include StatReference
  include Scoreable
  include Formattable

end
