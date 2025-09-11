angular.module('sportsbeep.factories').factory 'Contest', (Model) ->

  class Contest extends Model

    # constructor: (json) ->
    #   super(json)
    #   @players = $q.defer().promise
    #   @contest = ContestService.find @contest.id

    # getGame: (callback = angular.noop) ->
    #   @contest.$promise.then (data) =>
    #     @game = new Game(data.game)
    #     callback()
