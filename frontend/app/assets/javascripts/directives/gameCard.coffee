angular.module('sportsbeep.directives').directive 'gameCard', ->

  restrict: 'E'
  scope:
    game: '=sbGame'
    centerText: '=sbCenterCircleText'
    includeStartTime: '=sbIncludeStartTime'
  templateUrl: 'directives/game-card.html'
  replace: true