window.delay_timers = {}

window.delay = (name, callback, ms) ->
  if window.delay_timers[name]
    clearTimeout(window.delay_timers[name])
  window.delay_timers[name] = setTimeout(callback, ms)

ready = ->
  $('[data-auto-submit]').change ->
    $(this).parents('form').submit()

$(ready)
