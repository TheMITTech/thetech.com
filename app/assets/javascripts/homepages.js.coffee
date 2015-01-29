# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Homepage
  constructor: (@layout) ->

  remove_submodule: (uuid) ->
    $('.submodule[data-uuid=' + uuid + ']').remove()

    this.each_module (mod) ->
      $.each mod['submodules'], (i, v) ->
        if v['uuid'] == uuid
          mod['submodules'].splice(i, 1)

  append_submodule: (mod_uuid, json) ->
    this.each_module (mod) ->
      if mod['uuid'] == mod_uuid
        mod['submodules'].push(json)

  append_row: (json) ->
    @layout.push(json)

  remove_row: (uuid) ->
    $('.row[data-uuid=' + uuid + ']').remove()

    $.each @layout, (i, v) =>
      if v['uuid'] == uuid
        @layout.splice(i, 1)

  each_row: (callback) ->
    $.each @layout, (i, v) ->
      callback(v)

  each_module: (callback) ->
    this.each_row (row) ->
      $.each row['modules'], (i, v) ->
        callback(v)

  each_submodule: (callback) ->
    this.each_module (mod) ->
      $.each mod['submodules'], (i, v) ->
        callback(mod)

ready = ->
  if $('.homepages_show').length > 0
    window.homepage = new Homepage(gon.layout)

    $('#save_layout').click ->
      $('#save_layout_form input[name=layout]').val(JSON.stringify(window.homepage.layout))
      $('#save_layout_form').submit()
      false

    if $('.flash.success').length > 0
      $('.master-editing-toolbar').css('opacity', '1')

$(ready)