# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $('.asset-candidate').click ->
    CKEDITOR.instances.article_html.insertHtml('<img src="' + this.src + '">')

$(ready)