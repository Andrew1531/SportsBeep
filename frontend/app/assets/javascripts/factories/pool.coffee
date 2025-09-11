angular.module('sportsbeep.factories').factory 'Pool', (Model) ->

  class Pool extends Model

    constructor: (json) ->
      super(json)