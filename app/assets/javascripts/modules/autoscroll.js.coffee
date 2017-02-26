$(window).scroll ->
  if $(window).scrollTop() + $(window).height() > $(document).height() - 100
    return if $('[data-autoscroll-target]').length == 0
    if $('[data-autoscroll-target]').data('autoscroll-target').length > 0
      # $('[data-autoscroll-loading]').html("<i class='fa fa-circle-o-notch fa-spin'></i>")
      $('[data-autoscroll-loading]').html("<i class='fa fa-circle-o-notch fa-spin'></i>")
      $('#autoscroll_link').attr("href", $('[data-autoscroll-target]').data('autoscroll-target'))
      $('[data-autoscroll-target]').data('autoscroll-target', '')
      $.rails.handleRemote($('#autoscroll_link'))
  return