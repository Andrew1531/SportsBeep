class TimerState < ActiveRecord::Base
  belongs_to :ticket

  validates :encrypted_text, presence: true
  validates :value, presence: true

end
