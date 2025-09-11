angular.module('sportsbeep.factories').factory 'Player', (Model) ->

  class Player extends Model

    constructor: (game, json) ->
      @game = game
      super(json)
      @team = @getTeam(game, @team.id)
      @teamColor = @getTeamColor()
      @gamePosition = @getGamePosition()

    getGamePosition: ->
      if @game_position?
        { id: @game_position }
      else if @gamePosition
        @gamePosition
      else
        {}

    getTeam: (game, teamId) ->
      if game.home_team.id is teamId
        game.home_team
      else
        game.away_team

    getTeamColor: ->
      @team.primary_color