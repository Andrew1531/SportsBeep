angular.module('sportsbeep.services').service 'SquadService', (HttpService, Ticket, Player) ->

  class SquadService extends HttpService
    constructor: ->
      super '/api/:sport/tickets/:ticketId/squads/:squadName'

    find: (ticketId, squadName, callback = angular.noop) ->
      @service.get ticketId: ticketId, squadName: squadName, callback

  new SquadService