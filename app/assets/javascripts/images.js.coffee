# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('body#images_new').length > 0
    $('select[name=image\\[creation_piece_id\\]]').change ->
      value = this.value
      section_select = $('#section_id_select')

      if value
        section_select.hide()
      else
        section_select.show()

$(document).ready(ready)
$(document).on('page:load', ready)