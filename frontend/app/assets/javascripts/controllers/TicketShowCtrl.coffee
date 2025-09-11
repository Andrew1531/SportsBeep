angular.module('sportsbeep.controllers').controller 'TicketShowCtrl', ($scope, $stateParams, ticket, contest, game, CurrentContest, CurrentTicket, ChoosePlayerService, SquadService, ScoresheetService, GamePositionService, ChooseSquadTeamModalService, GameSquadService, TicketService, PlayerService, Ticket) ->

  $scope.getPlayerAtPosition = (position) ->
    CurrentTicket.getPlayerAtPosition(position)

  $scope.selectSquad = (ticketSquad) ->
    ticketSquad.gameSquad = { id: ticketSquad.game_position }
    ChooseSquadTeamModalService.show(ticketSquad, $scope.game).then (team) =>
      CurrentTicket.selectTeamForGameSquad(team, ticketSquad)
      $scope.squads = CurrentTicket.ticketSquads

  $scope.updateTicket = ->
    $spinner = $('.set-your-team .fa-spinner')
    $checkmark = $('.set-your-team .fa-check')
    $checkmark.hide()
    $spinner.show()
    TicketService.updateTicket($scope.ticket, CurrentTicket.serialize()).success (data) =>
      $spinner.hide()
      $checkmark.show()
    .error (data) ->
      $scope.error = data.error
      $spinner.hide()

  $scope.getScoresheetFor = (player) =>
    http = ScoresheetService.find $scope.ticket.id, player.id, (data) =>
      $scope.stats = data.stats
    http.$promise

  $scope.getSquadScoresheetFor = (squad) =>
    http = SquadService.find $scope.ticket.id, squad.game_position, (data) =>
      $scope.stats = data.stats
    http.$promise
