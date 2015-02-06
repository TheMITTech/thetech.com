# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

`/*
 * jQuery throttle / debounce - v1.1 - 3/7/2010
 * http://benalman.com/projects/jquery-throttle-debounce-plugin/
 *
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */
(function(b,c){var $=b.jQuery||b.Cowboy||(b.Cowboy={}),a;$.throttle=a=function(e,f,j,i){var h,d=0;if(typeof f!=="boolean"){i=j;j=f;f=c}function g(){var o=this,m=+new Date()-d,n=arguments;function l(){d=+new Date();j.apply(o,n)}function k(){h=c}if(i&&!h){l()}h&&clearTimeout(h);if(i===c&&m>e){l()}else{if(f!==true){h=setTimeout(i?k:l,i===c?e-m:e)}}}if($.guid){g.guid=j.guid=j.guid||$.guid++}return g};$.debounce=function(d,e,f){return f===c?a(d,e,false):a(d,f,e!==false)}})(this);`

$ ->
  $('#search_form').submit ->
    query = $(this).find('input[name=query]').val().replace(' ', '+')
    document.location.href = '/search/' + query
    return false

  # Toggle sidenav
  sidenav_width = 240

  $('.navbar-menu').on 'click touchstart', (e) ->
    e.preventDefault()
    $('body, .navbar, .sidenav, .container, footer').toggleClass 'in'
  $('body').on 'click touchstart', (e) ->
    if e.pageX > sidenav_width and $(this).hasClass 'in'
      $('body, .navbar, .sidenav, .container, footer').removeClass 'in'

  # Navbar scrolling
  nav_height = 50
  nameplate_height = 200
  last_st = 0;
  delta = 5
  vp_width = $(window).width()

  # Scroll to top
  $('.article-title').on 'click touchstart', (e) ->
    e.preventDefault();
    $('html, body').animate {scrollTop: 0}, 450

  # On scroll event
  $(window).scroll $.throttle 250, ->
    st = $(window).scrollTop()
    if !(Math.abs(last_st - st) <= delta)
      # The Tech => headline
      if $('body').hasClass 'frontend_pieces_show'
        if vp_width > 767
          if st > ($('.byline').position().top - nav_height)
            $('.article-title').removeClass 'hidden'
            $('.navbar-title').addClass 'hidden'
          else
            $('.article-title').addClass 'hidden'
            $('.navbar-title').removeClass 'hidden'

      # Scroll to hide/show nav
      if $('body').hasClass 'frontend_pieces_show'
        if st > last_st and st > nav_height
          $('.navbar').addClass 'up'
        else if st + $(window).height() < $(document).height()
          $('.navbar').removeClass 'up'
      else if $('body').hasClass 'frontend_homepage_show'
        if st > nameplate_height
          $('.navbar').removeClass 'up'
        else
          $('.navbar').addClass 'up'

    last_st = st