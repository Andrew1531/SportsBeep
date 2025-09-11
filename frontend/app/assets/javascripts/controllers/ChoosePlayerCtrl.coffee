angular.module('sportsbeep.controllers').controller 'ChoosePlayerCtrl', ($scope, $stateParams, ChoosePlayerService, CurrentTicket, GamePositionService) ->

  $scope.position = $stateParams.position
  playerPositionsForGamePosition = GamePositionService.playerPositionsFor(id: $stateParams.position)

  $scope.selectPlayer = (player, position) ->
    CurrentTicket.selectPlayerForGamePosition(player, { id: position })

  $scope.gamePlayers.then (players) ->
    playersOnTicketIDs = CurrentTicket.ticketPlayers.map (ticketPlayer) -> ticketPlayer.player.id

    $scope.players = players.filter (player) =>
      (player.position in playerPositionsForGamePosition) && (player.id not in playersOnTicketIDs)

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

