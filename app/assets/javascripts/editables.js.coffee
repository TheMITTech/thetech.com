ready = ->
  $(document).on 'dblclick', '[data-editable-url]', ->
    $(this).attr('contenteditable', 'true')


  $(document).on 'keypress', '[data-editable-url]', (event) ->
    keyCode = if event.keyCode then event.keyCode else event.which
    if (keyCode == 13)
      $(this).append($("<i class='fa fa-circle-o-notch fa-spin'></i>"))
      $(this).attr('contenteditable', 'false')

      form = $('#editable_form')
      form.attr('action', $(this).data('editable-url'))
      form.children('input[type=hidden]').attr('name', $(this).data('editable-object') + "[" + $(this).data('editable-field') + "]")
      form.children('input[type=hidden]').val($(this).text())
      $.rails.handleRemote(form)

    return true

$(document).ready(ready)
$(document).on('turbolinks:load', ready)
