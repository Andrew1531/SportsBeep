angular.module('sportsbeep.directives').directive 'teamNameBackdrop', ->

  restrict: 'E'
  scope:
    team: '=sbTeam'
    height: '=sbHeight'
  templateUrl: 'directives/team-name-backdrop.html'
  replace: true