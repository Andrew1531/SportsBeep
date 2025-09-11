angular.module('sportsbeep.services').factory 'ChoosePlayerService', ->

  class ChoosePlayerService
    constructor: ->
      @ticket = @players = undefined

    all: (params) ->
      @service.query(params)


  new ChoosePlayerService