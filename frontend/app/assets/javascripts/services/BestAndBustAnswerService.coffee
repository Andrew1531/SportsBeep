angular.module('sportsbeep.services').service 'BestAndBustAnswerService', ($http, GlobalOptions, HttpService) ->

  class BestAndBustAnswerService extends HttpService
    constructor: ->
      super '/api/:sport/tickets/:ticketId/answers'
      @indexRoot = 'answers'

    all: (params) ->
      @service.query(params)

    submit: (ticketId, payload) ->
      try
        $http.post "/api/#{GlobalOptions.get('sport')}/tickets/#{ticketId}/answers", payload
      catch

  new BestAndBustAnswerService