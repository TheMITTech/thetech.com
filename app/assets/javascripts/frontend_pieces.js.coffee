# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
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