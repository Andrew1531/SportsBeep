angular.module('sportsbeep.controllers').controller 'TicketCtrl', ($scope, ticket, contest, game, TicketPlayer, CurrentContest, CurrentTicket, ChoosePlayerService, SquadService, ScoresheetService, GamePositionService, GameSquadService, TicketService, PlayerService, Ticket) ->
  CurrentTicket.clear()
  CurrentContest.contest = contest

  CurrentTicket.fromTicket(ticket).then ->
    $scope.ticket = ticket
    $scope.contest = contest
    $scope.game = game
    $scope.positions = CurrentTicket.getAvailablePlayerPositions()
    $scope.ticketPlayers = CurrentTicket.ticketPlayers
    $scope.gamePlayers = PlayerService.forGame(game).$promise

    CurrentTicket.game = game

    gameSquads = GameSquadService.all()
    squads = $scope.ticket.squads

    $scope.players = $scope.ticketPlayers.map (tp) -> tp.player

    $scope.squads = squads.map (squad) =>
      for gameSquad in gameSquads
        squad.name = gameSquad.name if gameSquad.id is squad.game_position
      squad
