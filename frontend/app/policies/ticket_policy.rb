class TicketPolicy < Struct.new(:user, :ticket)

  def questions?
    ticket.user == user
  end

end
