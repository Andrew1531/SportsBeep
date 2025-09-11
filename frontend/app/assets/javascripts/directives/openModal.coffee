angular.module('sportsbeep.directives').directive 'openModal', ->

  restrict: 'A'
  link: (scope, elem, attrs) ->

    $(elem).on 'click', =>
      $('.container').addClass('blurred')
      $("##{attrs.openModal}").show()
