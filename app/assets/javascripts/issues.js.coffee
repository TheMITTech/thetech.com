# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#issues_show').length > 0
    $('.edit_article select').change ->
      $(this).parents('form').submit()

$(ready)