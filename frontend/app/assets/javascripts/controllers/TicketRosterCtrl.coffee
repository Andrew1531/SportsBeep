angular.module('sportsbeep.controllers').controller 'TicketRosterCtrl', ($scope, ChooseSquadTeamModalService, CurrentTicket) ->

  $scope.ticketInvalid = ->
    not CurrentTicket.isValid()