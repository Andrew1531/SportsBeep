angular.module('sportsbeep.factories').factory 'Model', ->

  class Model
    # copy JSON properties/values into this object
    constructor: (json) ->
      _.extend @, json
