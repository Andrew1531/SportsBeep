angular.module('sportsbeep.services').service 'GamePositionService', ($resource, GlobalOptions, GamePosition) ->

  class GamePositionService

    all: ->
      switch GlobalOptions.get('sport')
        when 'nfl'
          [
            new GamePosition('running_back', 'Running Back'),
            new GamePosition('wide_receiver', 'Wide Receiver'),
            new GamePosition('tight_end', 'Tight End'),
            new GamePosition('flex_player', 'Flex Player'),
            new GamePosition('kicker', 'Kicker')
          ]

    playerPositionsFor: (gamePosition) ->
      map =
        switch GlobalOptions.get('sport')
          when 'nfl'
            running_back: ['FB', 'HB', 'RB', 'TB', 'WB']
            tight_end: ['TE']
            wide_receiver: ['WR']
            kicker: ['K', 'PK']
            flex_player: ['RB', 'WR', 'TE']

      map[gamePosition.id]

  new GamePositionService