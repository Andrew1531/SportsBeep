angular.module('sportsbeep.services').service 'TicketService', ($http, HttpService, Ticket, GlobalOptions) ->

  class TicketService extends HttpService
    constructor: ->
      super '/api/:sport/tickets/:id'
      @indexRoot = 'games'

    createTicket: (params) ->
      $http.post "/api/#{GlobalOptions.get('sport')}/tickets", params

    updateTicket: (ticket, params) ->
      $http.put "/api/#{GlobalOptions.get('sport')}/tickets/#{ticket.id}", params

    jsonToModel: (data) ->
      new Ticket(data)

  new TicketService