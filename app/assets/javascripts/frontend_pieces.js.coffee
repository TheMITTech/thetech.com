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
  # Navbar scrolling
  nav_height = 50
  last_st = 0;
  delta = 5
  $(window).scroll $.throttle 250, ->
    st = $(window).scrollTop()
    if !(Math.abs(last_st - st) <= delta)
      # The Tech => headline
      if st > ($('.byline').position().top - nav_height)
        setTimeout (->
          $('.article-title').css 'display', 'block'
          $('.navbar-title').addClass 'hidden'
        ), 400
      else
        $('.article-title').fadeOut 200, ->
          $('.navbar-title').removeClass 'hidden'

      # Scroll to hide/show nav
      if (st > last_st && st > nav_height)
        $('.navbar').addClass 'up'
      else if (st + $(window).height() < $(document).height())
        $('.navbar').removeClass 'up'
    last_st = st