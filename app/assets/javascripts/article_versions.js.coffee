# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#article_versions_show').length > 0
    $('.edit_article_version select').change ->
      $(this).parents('form').submit()

  $("#diff_unified_button").on "click", ->
    $(".diff_table#sidebyside").hide()
    $(".diff_table#unified").show()


  $("#diff_side_button").on "click", ->
    $(".diff_table#unified").hide()
    $(".diff_table#sidebyside").show()


$(ready)

