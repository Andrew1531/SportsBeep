angular.module('sportsbeep.services').service 'CurrentContest', ->

  class CurrentContest
    constructor: ->
      @tickets = []
      @contest = undefined

  new CurrentContest