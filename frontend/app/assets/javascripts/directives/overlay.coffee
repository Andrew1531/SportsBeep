angular.module('sportsbeep.directives').directive 'overlay', ->

  restrict: 'E'
  templateUrl: 'directives/overlay.html'
  replace: true
  transclude: true