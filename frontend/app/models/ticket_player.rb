class TicketPlayer < ActiveRecord::Base
  belongs_to :ticket, touch: true
  belongs_to :player, touch: true
end
