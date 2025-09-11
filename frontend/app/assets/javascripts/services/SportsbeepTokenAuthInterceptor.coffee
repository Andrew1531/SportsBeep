angular.module('sportsbeep.services').factory 'SportsbeepTokenAuthInterceptor', ->

  class SportsbeepTokenAuthInterceptor
    request: (config) ->
      token = localStorage.getItem('authToken')
      if token?
        config.headers['Authorization'] = "Token token=#{token}"
      config

  new SportsbeepTokenAuthInterceptor