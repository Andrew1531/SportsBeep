angular.module('sportsbeep.services').service 'CurrentTicket', ($q, TicketPlayer, TicketSquad, GamePositionService, GameSquadService, NullPlayer, NullTeam, PlayerService) ->

  class CurrentTicket
    constructor: ->
      @ticketPlayers = $q.defer().promise
      @clear()

    fromTicket: (ticket) ->
      PlayerService.forTicket(ticket).$promise.then (players) =>
        @ticketPlayers = players.map (player) ->
          new TicketPlayer(player.gamePosition, player)
        @ticketSquads = ticket.squads

    getAvailablePlayerPositions: ->
      GamePositionService.all()

    getPlayerAtPosition: (position) ->
      for ticketPlayer in @ticketPlayers
        player = ticketPlayer.player
        return player if player.gamePosition.id is position.id

    selectPlayerForGamePosition: (player, gamePosition) ->
      for ticketPlayer in @ticketPlayers
        if ticketPlayer.gamePosition.id == gamePosition.id
          player.gamePosition = gamePosition
          ticketPlayer.player = player
          @update()

    selectTeamForGameSquad: (team, ticketSquad) ->
      gameSquad = ticketSquad.gameSquad || { id: ticketSquad.game_position }
      for ticketSquad in @ticketSquads
        if ticketSquad.gameSquad?.id == gameSquad.id || (ticketSquad.game_position? && (ticketSquad.game_position == gameSquad.id))
          ticketSquad.team = team
          @update()

    update: ->
      @updatedAt = new Date().getTime()

    serialize: ->
      serialization =
        ticket:
          players: @ticketPlayers.map (tp) ->
            id: tp.player.id
            position: tp.gamePosition.id
          squads: @ticketSquads.map (ts) ->
            id: ts.team.id
            position: (ts.gameSquad?.id || ts.game_position)
      serialization.game_id = @game.id if @game
      serialization.pool_id = @pool.id if @pool
      serialization

    isValid: ->
      for ticketPlayer in @ticketPlayers
        return false if ticketPlayer.player.null

      for ticketSquad in @ticketSquads
        return false if ticketSquad.team.null

      true

    clear: ->
      @ticketPlayers = []
      @ticketSquads = []

      for gamePosition in GamePositionService.all()
        @ticketPlayers.push new TicketPlayer(gamePosition, new NullPlayer())

      for gameSquad in GameSquadService.all()
        @ticketSquads.push new TicketSquad(gameSquad, new NullTeam())

      @update()

  new CurrentTicket