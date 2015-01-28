# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $(document).on('click', '.asset-candidate', ->
    CKEDITOR.instances.article_html.insertHtml('<img src="' + this.src + '">')
  )

  $(document).on('click', '.article_list', ->
    CKEDITOR.instances.article_html.insertHtml($(this).data('placeholder-html'))
  )

  if $('#articles_new, #articles_edit, #article_versions_revert').length > 0
    authors = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      local: gon.authors
    )

    authors.initialize()

    tagsinput = $('input[name=article\\[author_ids\\]]')
    tagsinput.tagsinput({
      itemValue: 'id',
      itemText: 'name',
      typeaheadjs: {
        name: 'authors',
        displayKey: 'name',
        source: authors.ttAdapter()
      }
    })

    for author in gon.prefilled_authors
      tagsinput.tagsinput('add', author)

  if $('#articles_index').length > 0
    $('#keywords').keyup ->
      window.delay('keywords_search', ->
        $('#keywords').parents('form').submit()
      , 300)

$(ready)