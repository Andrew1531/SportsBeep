angular.module('sportsbeep.services').service 'ContestTicketService', ($http, HttpService, Ticket, Contest) ->

  class ContestTicketService extends HttpService
    constructor: ->
      super '/api/:sport/contests/:contestId/tickets/:id'
      @indexRoot = 'tickets'

    jsonToModel: (data) ->
      new Ticket(data)

  new ContestTicketService