angular.module('sportsbeep.directives').directive 'bestAndBustCard', ->

  restrict: 'E'
  scope:
    score: '=sbScore'
  templateUrl: 'directives/best-and-bust-card.html'
  replace: true