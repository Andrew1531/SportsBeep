angular.module('sportsbeep.directives').directive 'squadCard', ->

  restrict: 'E'
  scope:
    squad: '=sbSquad'
    flipper: '=sbFlipper'
  templateUrl: 'directives/squad-card.html'
  replace: true
  link: (scope, element, _) ->

    unless scope.flipper is false
      element.on 'click', =>
        angular.element(element).toggleClass('flip')

        if !scope.stats?
          scope.$parent.$parent.getSquadScoresheetFor(scope.squad).then =>
            scope.stats = scope.$parent.stats