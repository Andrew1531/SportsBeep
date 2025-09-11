angular.module('sportsbeep.services').service 'AuthService', ($resource) ->

  class AuthService
    constructor: ->
      @service = $resource '/api/users/:_action', null,
        login:
          method: 'POST'
          params:
            _action: 'login'

    login: ->
      localStorage.setItem 'authToken', $('#auth-token').data('token')
      # @service.login user: {}, (data) ->
      #   localStorage.setItem 'authToken', data.authentication_token
      # @service.login.$promise

    getAuthToken: ->
      localStorage.getItem('authToken')

  new AuthService
