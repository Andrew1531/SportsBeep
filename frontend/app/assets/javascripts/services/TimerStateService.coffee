angular.module('sportsbeep.services').service 'TimerStateService', (HttpService) ->

  class TimerStateService extends HttpService
    constructor: ->
      super '/api/:sport/tickets/:ticketId/timer_states'
      @indexRoot = 'timer_states'

    all: (ticket) ->
      @service.query(ticketId: ticket.id)

  new TimerStateService