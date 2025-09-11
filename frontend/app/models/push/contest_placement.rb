class Push
  class ContestPlacement < Message

    attr_reader :ticket

    def initialize(ticket)
      @ticket = ticket
    end

    protected

      def body
        {
          type: 'placement',
          contest: ticket.contest.id,
          game: ticket.game.id,
          ticket: ticket.id,
          placing: ticket.placing,
          sport: ticket._sport.to_s.downcase
        }
      end

  end
end
