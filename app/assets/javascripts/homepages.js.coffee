# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Homepage
  constructor: (@layout) ->

  remove_submodule: (uuid) ->
    $('.module-sub[data-uuid=' + uuid + ']').remove()

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

  children_count: (path) ->
    el = this.get_layout_element_by_path(path)
    return el['modules'].length if el['modules']
    return el['submodules'].length if el['submodules']
    return 0

  prev_path: (path) ->
    switch path.length
      when 1 then [path[0] - 1]
      when 2
        if path[1] == 0
          [path[0] - 1, this.children_count([path[0] - 1]) - 1]
        else
          [path[0], path[1] - 1]

  next_path: (path) ->
    switch path.length
      when 1 then [path[0] + 1]
      when 2
        count = this.children_count([path[0]])
        if path[1] == count - 1
          [path[0] + 1, 0]
        else
          [path[0], path[1] + 1]

  of_compatible_size: (pa, pb) ->
    ea = this.get_layout_element_by_path(pa)
    eb = this.get_layout_element_by_path(pb)

    return ea['cols'] == eb['cols'] if (ea['cols'] && (pa[0] != pb[0]))
    return true

  move_row_upward: (uuid) ->
    [ea, pa] = this.get_layout_element(uuid)
    this.swap_paths(pa, this.prev_path(pa))
    @change_callback()

  move_row_downward: (uuid) ->
    [ea, pa] = this.get_layout_element(uuid)
    this.swap_paths(pa, this.next_path(pa))
    @change_callback()

  move_module_leftward: (uuid) ->
    [ea, pa] = this.get_layout_element(uuid)
    this.swap_paths(pa, this.prev_path(pa))
    @change_callback()

  move_module_rightward: (uuid) ->
    [ea, pa] = this.get_layout_element(uuid)
    this.swap_paths(pa, this.next_path(pa))
    @change_callback()

  get_element_by_uuid: (uuid) ->
    $('[data-uuid=' + uuid + ']')

  swap_elements: (ua, ub) ->
    [ca, pa] = this.get_layout_element(ua)
    [cb, pb] = this.get_layout_element(ub)

    unless this.of_compatible_size(pa, pb)
      alert('You can only swap elements of compatible sizes. ')
      return

    this.swap_layout_elements(ua, ub)
    this.swap_dom_elements(ua, ub)

  swap_paths: (pa, pb) ->
    ea = this.get_layout_element_by_path(pa)
    eb = this.get_layout_element_by_path(pb)

    if ea && eb
      this.swap_elements(ea['uuid'], eb['uuid'])

  get_layout_element: (uuid) ->
    result = null
    result_path = null
    this.each_row (row, path) ->
      [result, result_path] = [row, path] if row['uuid'] == uuid
    return [result, result_path] if result
    this.each_module (mod, path) ->
      [result, result_path] = [mod, path] if mod['uuid'] == uuid
    return [result, result_path] if result
    this.each_submodule (sub, path) ->
      [result, result_path] = [sub, path] if sub['uuid'] == uuid
    return [result, result_path] if result
    return [null, null]

  set_layout_element: (path, el) ->
    switch path.length
      when 1 then this.layout[path[0]] = el
      when 2 then this.layout[path[0]]['modules'][path[1]] = el
      when 3 then this.layout[path[0]]['modules'][path[1]]['submodules'][path[2]] = el

  get_layout_element_by_path: (path) ->
    return switch path.length
      when 1 then this.layout[path[0]]
      when 2 then this.layout[path[0]]['modules'][path[1]]
      when 3 then this.layout[path[0]]['modules'][path[1]]['submodules'][path[2]]

  swap_layout_elements: (ua, ub) ->
    [ca, pa] = this.get_layout_element(ua)
    [cb, pb] = this.get_layout_element(ub)

    if pa && pb
      this.set_layout_element(pa, cb)
      this.set_layout_element(pb, ca)

  swap_dom_elements: (ua, ub) ->
    ea = this.get_element_by_uuid(ua)
    eb = this.get_element_by_uuid(ub)
    tmp = ea[0].outerHTML
    ea.replaceWith(eb[0].outerHTML)
    eb.replaceWith(tmp)

  edit_submodule_field: (uuid, field, value) ->
    this.each_submodule (sub) =>
      if sub['uuid'] == uuid
        sub[field] = value
        @change_callback()

  each_row: (callback) ->
    $.each @layout, (i, v) ->
      callback(v, [i])

  each_module: (callback) ->
    this.each_row (row, path) ->
      $.each row['modules'], (i, v) ->
        callback(v, path.concat([i]))

  each_submodule: (callback) ->
    this.each_module (mod, path) ->
      $.each mod['submodules'], (i, v) ->
        callback(v, path.concat([i]))

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
      uuid = $(this).parents('.module-sub').data('uuid')
      field = $(this).data('editable')
      value = $(this).text()

      $(this).html(value)

      window.homepage.edit_submodule_field uuid, field, value


    $(window).on 'unload', ->
      console.log window.homepage.layout

    $(window).on 'beforeunload', ->
      if window.homepage_changed
        'Layout has been changed yet not saved. Discard changes? '
      else
        undefined

$(ready)