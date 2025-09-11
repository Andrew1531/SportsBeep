angular.module('sportsbeep.services').service 'ChooseSquadTeamModalService', ($q) ->

  class ChooseSquadTeamModalService
    constructor: ->

    show: (squad, game) ->
      @d = $q.defer()
      @squad = squad
      @game = game
      promise = @d.promise

      promise.finally ->
        $('.container').removeClass('blurred')
        $('#squad-overlay').hide()

      $('.container').addClass('blurred')
      $('#squad-overlay').show()

      promise

  new ChooseSquadTeamModalService
