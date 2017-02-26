fire_event = (event, val) ->
  if val
    $('[data-hide-on=' + event + ']').hide()
    $('[data-show-on=' + event + ']').show()
  else
    $('[data-hide-on=' + event + ']').show()
    $('[data-show-on=' + event + ']').hide()

$(document).on 'click', '[data-hide-trigger]', ->
  trigger = $(this).data('hide-trigger')

  if $(this).is(":checkbox")
    fire_event(trigger, $(this).prop('checked'))
  else if $(this).is("a")
    fire_event(trigger, $(this).data('hide-value'))
    return false

  return true
