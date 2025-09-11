angular.module('sportsbeep.services').service 'TeamService', ($http, HttpService) ->

  class TeamService extends HttpService
    constructor: ->
      super '/api/:sport/teams'
      @teams = @index()
      @indexRoot = 'teams'

    find: (id) ->
      for team in @teams
        return team if team.id is id

  new TeamService