class TimerState < ActiveRecord::Base
  before_save { SportsbookOnly.reject! }
  before_destroy { SportsbookOnly.reject! }
  belongs_to :ticket

  validates :encrypted_text, presence: true
  validates :value, presence: true

end
