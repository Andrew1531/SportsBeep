angular.module('sportsbeep.controllers').controller 'ChooseSquadTeamModalCtrl', ($scope, CurrentTicket, ChooseSquadTeamModalService) ->

  $scope.$watch (-> CurrentTicket.game), (game) ->
    $scope.game = game

  $scope.$watch (-> ChooseSquadTeamModalService.squad), (squad) ->
    if squad
      $scope.squad = squad
      $scope.squad.name = squad.name if squad.name


  $scope.selectHomeTeam = ->
    ChooseSquadTeamModalService.d.resolve $scope.game.home_team

  $scope.selectAwayTeam = ->
    ChooseSquadTeamModalService.d.resolve $scope.game.away_team