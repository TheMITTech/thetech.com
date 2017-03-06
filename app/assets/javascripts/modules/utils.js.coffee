$.timeago.settings.strings.minute = "a minute"
$.timeago.settings.strings.hour = "an hour"
$.timeago.settings.strings.day = "a day"
$.timeago.settings.strings.month = "a month"
$.timeago.settings.strings.year = "a year"
$.timeago.settings.strings.seconds = "seconds"

@pluralize = (count, word) ->
  if count == 1 then word else "#{word}s"

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

@logError = (message) ->
  console.error(message)

@range = (start, end) ->
  [start..end]
