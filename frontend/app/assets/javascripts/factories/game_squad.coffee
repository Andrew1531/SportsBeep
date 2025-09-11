angular.module('sportsbeep.factories').factory 'GameSquad', ->

  class GameSquad
    constructor: (id, name, score = 0.0) ->
      @id = id
      @name = name
      @score = score