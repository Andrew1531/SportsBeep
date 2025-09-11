angular.module('sportsbeep.services').factory 'PlayerService', ($resource, HttpService, Player) ->

  class PlayerService extends HttpService
    constructor: (@game) ->
      @indexRoot = 'players'
      @includeSquads = false
      super '/api/:sport/:resource/:resourceId/players/:id'

    all: (params) ->
      @service.query(params)

    forGame: (game) ->
      @game = game
      @service.query(resource: 'games', resourceId: @game.id)

    forTicket: (ticket) ->
      @game = undefined
      @ticket = ticket
      @includeSquads = true
      @service.query(resource: 'tickets', resourceId: @ticket.id)

    jsonToModel: (data) ->
      if @game
        new Player(@game, data)
      else if @ticket
        new Player(@ticket.game, data)

    actionOptions: ->
      query:
        method: 'GET'
        isArray: true
        transformResponse: (data) =>
          response = []
          wrapped = angular.fromJson(data)
          angular.forEach wrapped[@indexRoot], (item) =>
            response.push @jsonToModel(item)

          @ticket.squads = wrapped['squads'] if @includeSquads
          response


  new PlayerService