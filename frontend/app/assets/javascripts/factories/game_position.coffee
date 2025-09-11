angular.module('sportsbeep.factories').factory 'GamePosition', ->

  class GamePosition
    constructor: (id, name) ->
      @id = id
      @name = name