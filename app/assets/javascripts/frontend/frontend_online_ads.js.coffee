$ ->
  $.getJSON '/niceties/manifest', (manifest) ->
    $('[data-ads]').each (i, ad) ->
      if $('article[data-allow-ads=false]').length > 0
        return

      position = $(ad).data('ads')
      candidates = manifest[position]


      if candidates.length > 0
        candidateIndex = Math.floor(Math.random() * candidates.length)
        choice = candidates[candidateIndex]
        candidates.splice(candidateIndex, 1)//removes that ad from the running
        //we currently have room for 3 article ads
        ad.src = choice.image

        if (choice.link)
          a = $('<a/>').attr('href', choice.link).addClass("article-ad")
          $(ad).wrap(a);

        $(ad).show()
