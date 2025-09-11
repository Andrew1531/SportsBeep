angular.module('sportsbeep.factories').factory 'TicketSquad', ->

  class TicketSquad
    constructor: (@gameSquad, @team) ->
      @name = @gameSquad.name
      @gameSquad.team = @team