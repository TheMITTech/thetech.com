# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('body#images_new').length > 0
    $('select[name=piece_id]').change ->
      value = this.value
      embedded_fields = $('#pieces_embedded_fields')

      if value
        embedded_fields.hide()
      else
        embedded_fields.show()

$(document).ready(ready)
$(document).on('page:load', ready)