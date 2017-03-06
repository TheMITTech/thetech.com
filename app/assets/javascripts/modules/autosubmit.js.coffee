ready = ->
  $(document).on 'change', '[data-auto-submit]', ->
    form = $(this).parents('form')

    if form.data('remote')
      $.rails.handleRemote(form)
    else
      $(this).parents('form').submit()

$(ready)
