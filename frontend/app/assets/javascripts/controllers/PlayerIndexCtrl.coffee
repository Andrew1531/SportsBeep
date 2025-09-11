angular.module('sportsbeep.controllers').controller 'PlayerIndexCtrl', ($scope, $stateParams, GamePositionService, PlayerService, CurrentTicket) ->

  gamePosition = { id: $stateParams.position }
  playerPositionsForGamePosition = GamePositionService.playerPositionsFor(gamePosition)

  $scope.headerText = $stateParams.position.replace('_', ' ')

  $scope.game.$promise.then =>
    playerIdsOnCurrentTicket = CurrentTicket.ticketPlayers.map (tp) -> tp.player.id

    $scope.game.players.$promise.then (data) =>
      $scope.players = data.filter (player) =>
        (player.position in playerPositionsForGamePosition) && (player.id not in playerIdsOnCurrentTicket)

      # sort players by first name first
      $scope.players = $scope.players.sort (a, b) ->
        if a.name.toUpperCase() > b.name.toUpperCase() then 1 else -1

      # reorganize players into every-other-team order
      homeTeamPlayers = $scope.players.filter (player) -> player.team.id == $scope.game.home_team.id
      awayTeamPlayers = $scope.players.filter (player) -> player.team.id == $scope.game.away_team.id

      maxSize = Math.max(homeTeamPlayers.length, awayTeamPlayers.length)
      players = []
      for i in [0..maxSize]
        players.push homeTeamPlayers[i] if homeTeamPlayers[i]
        players.push awayTeamPlayers[i] if awayTeamPlayers[i]

      $scope.players = players


  $scope.selectPlayer = (player) ->
    CurrentTicket.selectPlayerForGamePosition(player, gamePosition)