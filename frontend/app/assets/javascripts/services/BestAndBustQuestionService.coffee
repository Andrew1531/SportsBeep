angular.module('sportsbeep.services').service 'BestAndBustQuestionService', (HttpService, Pool, BestAndBustQuestion) ->

  class BestAndBustQuestionService extends HttpService
    constructor: ->
      super '/api/:sport/tickets/:ticketId/questions'
      @indexRoot = 'questions'

    all: (ticket) ->
      @service.query(ticketId: ticket.id)

    jsonToModel: (data) ->
      new BestAndBustQuestion(data)

  new BestAndBustQuestionService