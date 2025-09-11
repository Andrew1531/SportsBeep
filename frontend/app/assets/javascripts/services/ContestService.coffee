angular.module('sportsbeep.services').factory 'ContestService', ($resource, HttpService) ->

  class ContestService extends HttpService
    constructor: (@game) ->
      @indexRoot = 'contests'
      super '/api/:sport/contests/:id'

    all: (params) ->
      @service.query(params)


  new ContestService