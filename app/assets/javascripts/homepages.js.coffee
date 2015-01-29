# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Homepage
  constructor: (@layout) ->

  remove_submodule: (uuid) ->
    $('.submodule[data-uuid=' + uuid + ']').remove()

    this.each_module (mod) =>
      $.each mod['submodules'], (i, v) =>
        if v['uuid'] == uuid
          mod['submodules'].splice(i, 1)
          @change_callback()

  append_submodule: (mod_uuid, json) ->
    this.each_module (mod) =>
      if mod['uuid'] == mod_uuid
        mod['submodules'].push(json)
        @change_callback()

  append_row: (json) ->
    @layout.push(json)
    @change_callback()

  remove_row: (uuid) ->
    $('.row[data-uuid=' + uuid + ']').remove()

    $.each @layout, (i, v) =>
      if v['uuid'] == uuid
        @layout.splice(i, 1)
        @change_callback()

  move_row_upward: (uuid) ->
    $.each @layout, (i, v) =>
      if v['uuid'] == uuid
        if i > 0
          tmp = @layout[i - 1]
          @layout[i - 1] = @layout[i]
          @layout[i] = tmp

          this.get_element_by_uuid(uuid).after(this.get_element_by_uuid(tmp['uuid']))
          @change_callback()
        return false

  move_row_downward: (uuid) ->
    $.each @layout, (i, v) =>
      if v['uuid'] == uuid
        if i + 1 < @layout.length
          tmp = @layout[i + 1]
          @layout[i + 1] = @layout[i]
          @layout[i] = tmp

          this.get_element_by_uuid(uuid).before(this.get_element_by_uuid(tmp['uuid']))
          @change_callback()
        return false

  move_module_leftward: (uuid) ->
    this.each_row (row) =>
      $.each row['modules'], (i, v) =>
        if v['uuid'] == uuid
          if i > 0
            tmp = row['modules'][i - 1]
            row['modules'][i - 1] = row['modules'][i]
            row['modules'][i] = tmp

            this.get_element_by_uuid(uuid).after(this.get_element_by_uuid(tmp['uuid']))
            @change_callback()
          return false

  move_module_rightward: (uuid) ->
    this.each_row (row) =>
      $.each row['modules'], (i, v) =>
        if v['uuid'] == uuid
          if i + 1 < row['modules'].length
            tmp = row['modules'][i + 1]
            row['modules'][i + 1] = row['modules'][i]
            row['modules'][i] = tmp

            this.get_element_by_uuid(uuid).before(this.get_element_by_uuid(tmp['uuid']))
            @change_callback()
          return false

  get_element_by_uuid: (uuid) ->
    $('[data-uuid=' + uuid + ']')

  edit_submodule_field: (uuid, field, value) ->
    this.each_submodule (sub) =>
      if sub['uuid'] == uuid
        sub[field] = value
        @change_callback()

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
        callback(v)

  on_change: (callback) ->
    @change_callback = callback

jQuery.fn.toggleAttr = (attr) ->
  @each ->
    $this = $(this)
    (if $this.attr(attr) then $this.removeAttr(attr) else $this.attr(attr, "true"))
    return

ready = ->
  if $('.homepages_show').length > 0
    window.homepage = new Homepage(gon.layout)
    window.homepage.on_change ->
      window.homepage_changed = true

    $('#save_layout').click ->
      $(window).unbind('beforeunload')
      $('#save_layout_form input[name=layout]').val(JSON.stringify(window.homepage.layout))
      $('#save_layout_form').submit()
      false

    if $('.flash').length > 0
      $('.master-editing-toolbar').css('opacity', '1')

    $(document).on 'dblclick', '*[data-editable]', ->
      $(this).toggleAttr('contenteditable')

    $(document).on 'blur keyup paste input', '*[data-editable]', ->
      uuid = $(this).parents('.submodule').data('uuid')
      field = $(this).data('editable')
      value = $(this).text()

      window.homepage.edit_submodule_field uuid, field, value


    $(window).on 'unload', ->
      console.log window.homepage.layout

    $(window).on 'beforeunload', ->
      if window.homepage_changed
        'Layout has been changed yet not saved. Discard changes? '
      else
        undefined

$(ready)