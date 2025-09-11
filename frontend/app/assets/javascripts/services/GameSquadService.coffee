angular.module('sportsbeep.services').service 'GameSquadService', ($resource, GlobalOptions, GameSquad) ->

  class GameSquadService

    all: ->
      switch GlobalOptions.get('sport')
        when 'nfl'
          [
            new GameSquad('quarterbacks', 'Quarterback'),
            new GameSquad('defense', 'Defense'),
            new GameSquad('special_teams', 'Special teams')
          ]

  new GameSquadService