# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->

  $(document).on 'change', '#question_topic', ->
    selectedText = $('option:selected', $(this)).text()
    $connotation = $('.connotation')

    if !!selectedText
      $('.topic').text(selectedText.toLowerCase())
      $connotation.removeClass 'hidden'
    else
      $connotation.addClass 'hidden'