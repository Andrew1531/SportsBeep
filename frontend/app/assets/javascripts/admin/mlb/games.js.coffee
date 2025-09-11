# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->

  $('#games td.bettable-column input').on 'change', (e) ->
    return unless $(this).is(':checked')

    $.ajax
      type: 'PUT',
      url: $(this).data('href')
      data: { game: { bettable: true } }
      success: =>
        $row = $(this).closest 'tr'
        $row.load(location.href + ' tr[data-href="' + $row.data('href') + '"] > *')
      error: =>
        $(this).prop('checked', false)
