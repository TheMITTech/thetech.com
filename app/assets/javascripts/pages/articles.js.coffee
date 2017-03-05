# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  if $('#articles_new, #articles_create, #articles_edit, #articles_update, #article_versions_revert').length > 0
    substringMatcher = (q, cb) ->
      matches = undefined
      substringRegex = undefined
      matches = []
      substrRegex = new RegExp("\\b" + q, 'i')
      $.each gon.authors, (i, author) ->
        if substrRegex.test(author.name)
          matches.push author
      cb matches

    tagsinput = $('input[name=draft\\[comma_separated_author_ids\\]]')
    tagsinput.tagsinput({
      itemValue: 'id',
      itemText: 'name',
      typeaheadjs: {
        name: 'authors',
        displayKey: 'name',
        source: substringMatcher
      }
    })

    for author in gon.prefilled_authors
      tagsinput.tagsinput('add', author)

  if $('#articles_index').length > 0
    $('#keywords').keyup ->
      window.delay('keywords_search', ->
        $('#keywords').parents('form').submit()
      , 300)

$(document).ready(ready)
$(document).on('page:load', ready)