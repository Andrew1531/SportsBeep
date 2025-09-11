# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.collapsed', ->
  $(this).addClass 'uncollapsed'
  $(this).removeClass 'collapsed'
  $(this).find('.collapsed-content').show()

$(document).on 'click', '.uncollapsed', ->
  $(this).addClass 'collapsed'
  $(this).removeClass 'uncollapsed'
  $(this).find('.collapsed-content').hide()

