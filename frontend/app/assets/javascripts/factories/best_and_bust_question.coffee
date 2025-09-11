angular.module('sportsbeep.factories').factory 'BestAndBustQuestion', (Model) ->

  class BestAndBustQuestion extends Model

    constructor: (json) ->
      super(json)