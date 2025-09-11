class NotifyWinners
  include Sidekiq::Worker

  def perform(ticket_ids)
    @tickets = Ticket.where(id: ticket_ids)
    @tickets.each do |ticket|
      notify(ticket) unless ticket.placing.nil?
    end
  end

  private

    def notify(ticket)
      Push::ContestPlacement.new(ticket).send_to ticket.user
    end

end