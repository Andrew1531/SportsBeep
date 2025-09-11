angular.module('sportsbeep.directives').directive 'mobileGameCard', ->

  restrict: 'E'
  scope:
    game: '=sbGame'
  templateUrl: 'directives/mobile-game-card.html'
  replace: true