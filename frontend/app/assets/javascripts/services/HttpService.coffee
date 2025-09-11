angular.module('sportsbeep.services').service 'HttpService', ($resource, GlobalOptions, Model) ->

  class HttpService
    constructor: (url) ->
      @url = url
      @service = $resource url, @defaultParams(), @actionOptions()

    jsonToModel: (data) ->
      new Model(data)

    find: (id, callback = angular.noop) ->
      @service.get id: id, callback

    index: (params) ->
      @service.query(params)

    sport: ->
      GlobalOptions.get('sport')

    defaultParams: ->
      sport: @sport()
      id: '@id'

    actionOptions: ->
      query:
        method: 'GET'
        isArray: true
        transformResponse: (data) =>
          response = []
          wrapped = angular.fromJson(data)
          angular.forEach wrapped[@indexRoot], (item) =>
            response.push @jsonToModel(item)
          response
