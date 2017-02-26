window.delay_timers = {}

window.delay = (name, callback, ms) ->
  if window.delay_timers[name]
    clearTimeout(window.delay_timers[name])
  window.delay_timers[name] = setTimeout(callback, ms)

ready = ->
  $(document).on 'change', '[data-auto-submit]', ->
    form = $(this).parents('form')

    if form.data('remote')
        $.rails.handleRemote(form)
    else
        $(this).parents('form').submit()

$(ready)
