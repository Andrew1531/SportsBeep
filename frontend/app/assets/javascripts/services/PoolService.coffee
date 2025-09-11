angular.module('sportsbeep.services').service 'PoolService', (HttpService, Pool) ->

  class PoolService extends HttpService
    constructor: ->
      super '/api/:sport/games/:gameId/pools'
      @indexRoot = 'pools'

    all: (game) ->
      @service.query(gameId: game.id)

    jsonToModel: (data) ->
      new Pool(data)

  new PoolService