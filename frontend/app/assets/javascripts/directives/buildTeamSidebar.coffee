angular.module('sportsbeep.directives').directive 'BuildTeamSidebar', ->

  restrict: 'E'
  scope:
    game: '=sb-build-team-sidebar'
  templateUrl: 'directives/build-team-sidebar.html'
  replace: true