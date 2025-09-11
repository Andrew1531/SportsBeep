angular.module('sportsbeep.directives').directive 'playerCard', ->

  restrict: 'E'
  scope:
    getPlayer: '&sbPlayer'
  templateUrl: 'directives/player-card.html'
  replace: true
  link: (scope, element) ->
    scope.$watch 'getPlayer()', (newVal) ->
      scope.player = newVal