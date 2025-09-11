angular.module('sportsbeep.directives').directive 'ticketCard', ->

  restrict: 'E'
  scope:
    ticket: '=sbTicket'
  templateUrl: 'directives/ticket-card.html'
  replace: true