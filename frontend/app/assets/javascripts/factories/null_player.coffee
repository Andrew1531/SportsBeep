angular.module('sportsbeep.factories').factory 'NullPlayer', ->

  class NullPlayer
    constructor: ->
      @number = '00'
      @null = true
      @id = -1