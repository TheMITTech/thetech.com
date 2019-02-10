normalizeQuotes = (el) ->
  start = el.selectionStart
  end = el.selectionEnd
  text = $(el).val()
  originalText = text.replace(/\u2018/g, '\'')
                     .replace(/\u2019/g, '\'')
                     .replace(/\u2032/g, '\'')
                     .replace(/\u2033/g, '"')
                     .replace(/\u201C/g, '"')
                     .replace(/\u201D/g, '"')
  converted = originalText.replace(/'(\d\d)/, "\u2019$1")           # Abbreviated year, e.g. '17

                          .replace(/'\b/g, "\u2018") # Smart single quote
                          .replace(/\b'\b/, "\u2019") 
                          .replace(/\b'/g, "\u2019")
                          .replace(/(\. ?)'/g, "$1\u2019")
                          .replace(/(\? ?)'/g, "$1\u2019")
                          .replace(/(, ?)'/g, "$1\u2019")
                          .replace(/(! ?)'/g, "$1\u2019")
                          .replace(/(; ?)'/g, "$1\u2019")

                          .replace(/"\b/g, "\u201c")                # Smart double quotes
                          .replace(/\b"/g, "\u201d")
                          .replace(/(\. ?)"/g, "$1\u201d")
                          .replace(/(\? ?)"/g, "$1\u201d")
                          .replace(/(, ?)"/g, "$1\u201d")
                          .replace(/(! ?)"/g, "$1\u201d")
                          .replace(/(; ?)"/g, "$1\u201d")

                          .replace(/--/g,  "\u2013")                # En dash
  $(el).val(converted)
  el.setSelectionRange(start, end)

$(document).on 'keypress', '[data-smart-quotes]', (e) ->
  setTimeout normalizeQuotes.bind(null, e.target), 0
  true

$(document).on 'paste', '[data-smart-quotes]', (e) ->
  setTimeout normalizeQuotes.bind(null, e.target), 0
  true
