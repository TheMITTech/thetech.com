# jQuery timeago plugin format customization

$.timeago.settings.strings.seconds = "seconds"
$.timeago.settings.strings.minute = "a minute"
$.timeago.settings.strings.minutes = "%d minutes"
$.timeago.settings.strings.hour = "an hour"
$.timeago.settings.strings.hours = "%d hours"
$.timeago.settings.strings.day = "a day"
$.timeago.settings.strings.days = "%d days"
$.timeago.settings.strings.month = "a month"
$.timeago.settings.strings.months = "%d months"
$.timeago.settings.strings.year = "a year"
$.timeago.settings.strings.years = "%d years"

# Utility global functions

@pluralize = (count, word) ->
  if count == 1 then word else "#{word}s"

@logError = (message) ->
  console.error(message)

@range = (start, end) ->
  [start..end]

window.delay_timers = {}

window.delay = (name, callback, ms) ->
  if window.delay_timers[name]
    clearTimeout(window.delay_timers[name])
  window.delay_timers[name] = setTimeout(callback, ms)
