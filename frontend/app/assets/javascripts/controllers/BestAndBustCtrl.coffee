angular.module('sportsbeep.controllers').controller 'BestAndBustCtrl', ($scope, $stateParams, TicketService, Ticket, BestAndBustAnswerService, TeamService) ->

  TicketService.find $stateParams.ticketId, (data) ->
    $scope.ticket = new Ticket(data)
    $scope.answers = []

    BestAndBustAnswerService.all({ ticketId: $stateParams.ticketId }).$promise.then (data) ->
      for d in data
        d.team = TeamService.find(d.team.id)
        $scope.answers.push d


