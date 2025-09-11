angular.module('sportsbeep.directives').directive 'playerScoreCard', ->

  restrict: 'E'
  scope:
    player: '=sbPlayer'
  templateUrl: 'directives/player-score-card.html'
  replace: true
  link: (scope, element, _) ->
    element.on 'click', =>
      angular.element(element).toggleClass('flip')

      if !scope.stats?
        scope.$parent.$parent.getScoresheetFor(scope.player).then =>
          scope.stats = scope.$parent.stats