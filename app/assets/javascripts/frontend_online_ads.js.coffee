$ ->
  $.getJSON '/niceties-manifest', (manifest) ->
    $('[data-ads]').each (i, ad) ->
      if $('article[data-allow-ads=false]').length > 0
        return

      position = $(ad).data('ads')
      candidates = manifest[position]

      if candidates.length > 0
        choice = candidates[Math.floor(Math.random() * candidates.length)]
        ad.src = choice.image

        if (choice.link)
          a = $('<a/>').attr('href', choice.link)
          $(ad).wrap(a);

        $(ad).show()
