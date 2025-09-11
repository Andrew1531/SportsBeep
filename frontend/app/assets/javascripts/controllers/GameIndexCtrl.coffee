angular.module('sportsbeep.controllers').controller 'GameIndexCtrl', ($scope, GameService) ->

  $scope.games = GameService.all()