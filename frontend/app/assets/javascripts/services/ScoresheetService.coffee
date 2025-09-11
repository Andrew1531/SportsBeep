angular.module('sportsbeep.services').service 'ScoresheetService', (HttpService, Ticket, Player) ->

  class ScoresheetService extends HttpService
    constructor: ->
      super '/api/:sport/tickets/:ticketId/players/:playerId/scoresheet'

    find: (ticketId, playerId, callback = angular.noop) ->
      @service.get ticketId: ticketId, playerId: playerId, callback

  new ScoresheetService