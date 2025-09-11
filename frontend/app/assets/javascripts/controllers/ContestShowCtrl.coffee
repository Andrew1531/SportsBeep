angular.module('sportsbeep.controllers').controller 'ContestShowCtrl', ($scope, $stateParams, ContestTicketService, ContestService, Contest, CurrentContest) ->

  ContestService.find $stateParams.id, (data) ->
    $scope.contest = new Contest(data)
    $scope.tickets = ContestTicketService.index(contestId: $stateParams.id)

    $scope.tickets.$promise.then (data) ->
      CurrentContest.tickets = $scope.tickets
      CurrentContest.contest = $scope.contest