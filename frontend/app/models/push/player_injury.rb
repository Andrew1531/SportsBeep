class Push
  class PlayerInjury < Message

    attr_reader :player, :ticket

    def initialize(player, ticket)
      @player = player
      @ticket = ticket
    end

    protected

      def body
        {
          type: 'injury',
          player: {
            id: player.id,
            name: player.name
          },
          ticket: ticket.id,
          game: ticket.game.id,
          sport: ticket._sport.to_s.downcase
        }
      end

  end
end