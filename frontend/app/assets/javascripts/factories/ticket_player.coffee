angular.module('sportsbeep.factories').factory 'TicketPlayer', ->

  class TicketPlayer
    constructor: (@gamePosition, @player) ->
      @player.gamePosition = @gamePosition