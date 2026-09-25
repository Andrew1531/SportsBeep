class TicketPlayer < ActiveRecord::Base
  before_save { SportsbookOnly.reject! }
  before_destroy { SportsbookOnly.reject! }
  belongs_to :ticket, touch: true
  belongs_to :player, touch: true
end
