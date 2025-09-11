class Push
  class PlayerPositionUpdate < Message

    attr_reader :player, :ticket, :position

    def initialize(player, ticket)
      @player = player
      @ticket = ticket
      @position = player.position_in(ticket.game)
    end

    protected

      def body
        {
          type: 'position_update',
          player: {
            id: player.id,
            name: player.name,
            position: position
          },
          ticket: ticket.id,
          game: ticket.game.id
        }
      end

  end
end