angular.module('sportsbeep.controllers').controller 'DashboardCtrl', ($scope, $stateParams, ContestService, CurrentContest) ->

  CurrentContest.contest = null

  $scope.filterContests = (status) ->
    $scope.contestStatus = status
    $scope.contests = []
    $scope.contests = ContestService.all(status: $scope.contestStatus)

  $scope.filterContests('upcoming')

  $scope.$watch (-> CurrentContest.contest), (newVal) ->
    $scope.hasContest = newVal?