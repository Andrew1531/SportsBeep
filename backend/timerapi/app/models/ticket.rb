class Ticket < ActiveRecord::Base
  has_many :ticket_timer_states, dependent: :delete_all
  has_many :ticket_answers, dependent: :delete_all
end
