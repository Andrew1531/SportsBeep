angular.module('sportsbeep.controllers').controller 'GameShowCtrl', ($scope, $stateParams, GameService, GamePositionService, GameSquadService, CurrentTicket, PlayerService, ChooseSquadTeamModalService) ->

  $scope.game = GameService.find $stateParams.id, (data) ->
    $scope.gamePositions = GamePositionService.all()
    $scope.gameSquads = GameSquadService.all()
    $scope.game.players = PlayerService.forGame($scope.game)
    CurrentTicket.game = $scope.game

  CurrentTicket.clear()
  $scope.currentTicket = CurrentTicket

  $scope.selectSquad = (ticketSquad, game) ->
    ChooseSquadTeamModalService.show(ticketSquad, game).then (team) =>
      CurrentTicket.selectTeamForGameSquad(team, ticketSquad)

  $scope.$watch 'currentTicket.updatedAt', =>
    $scope.players = $scope.currentTicket.ticketPlayers.map (tp) ->
      tp.player

    $scope.ticketSquads = $scope.currentTicket.ticketSquads