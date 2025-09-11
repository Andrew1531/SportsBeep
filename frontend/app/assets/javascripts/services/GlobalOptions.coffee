angular.module('sportsbeep.services').service 'GlobalOptions', ->

  class GlobalOptions
    get: (key) ->
      if key is 'sport' then 'nfl'

  new GlobalOptions
