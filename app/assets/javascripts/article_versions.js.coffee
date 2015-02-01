# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#article_versions_show').length > 0
    $('.edit_article_version select').change ->
      $(this).parents('form').submit()

$(ready)
