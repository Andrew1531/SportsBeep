angular.module('sportsbeep.factories').factory 'Game', (Model) ->

  class Game extends Model

    constructor: (json) ->
      @players = []
      super(json)