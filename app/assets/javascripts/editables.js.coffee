ready = ->
  jQuery.fn.selectText = ->
    `var range`
    @find('input').each ->
      if $(this).prev().length == 0 or !$(this).prev().hasClass('p_copy')
        $('<p class="p_copy" style="position: absolute; z-index: -1;"></p>').insertBefore $(this)
      $(this).prev().html $(this).val()
      return
    doc = document
    element = @[0]
    if doc.body.createTextRange
      range = document.body.createTextRange()
      range.moveToElementText element
      range.select()
    else if window.getSelection
      selection = window.getSelection()
      range = document.createRange()
      range.selectNodeContents element
      selection.removeAllRanges()
      selection.addRange range
    return

  submitEditableForm = (el) ->
    el.append($("<i class='fa fa-circle-o-notch fa-spin'></i>"))

    form = $('#editable_form')
    form.attr('action', el.data('editable-url'))
    form.children('input[type=hidden]').attr('name', el.data('editable-object') + "[" + el.data('editable-field') + "]")
    form.children('input[type=hidden]').val(el.text())
    $.rails.handleRemote(form)

  $(document).on 'click', '[data-editable-url]', ->
    if $(this).attr('contenteditable') == 'true'
      return

    $(this).attr('contenteditable', 'true')
    $(this).data('editable-original', $(this).text())
    $(this).selectText()

  $(document).on 'focusout', '[data-editable-url]', ->
    $(this).attr('contenteditable', 'false')

    if $(this).text() != $(this).data('editable-original')
      if confirm("Do you want to save your change? ")
        submitEditableForm($(this))
      else
        $(this).text($(this).data('editable-original'))

  $(document).on 'keypress', '[data-editable-url]', (event) ->
    keyCode = if event.keyCode then event.keyCode else event.which
    if keyCode == 13
      $(this).attr('contenteditable', 'false')
      submitEditableForm($(this))
    return true

$(document).ready(ready)
$(document).on('turbolinks:load', ready)
