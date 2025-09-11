angular.module('sportsbeep.services').service 'GameService', (HttpService, Game) ->

  class GameService extends HttpService
    constructor: ->
      super '/api/:sport/games/:id'
      @indexRoot = 'games'

    all: ->
      @service.query()

    jsonToModel: (data) ->
      new Game(data)

  new GameService