module ApplicationHelper

  # Writes a given DateTime (e.g., a publication date) as a human-friendly
  # string, using an 'ago' phrase if the date is today.
  #
  # date - a DateTime
  #
  # Examples
  #
  # date_in_words(DateTime.new(1990, 2, 3, 4, 5, 6))
  #   => "Feb 3, 1990"
  # date_in_words(DateTime.now)
  #   => "less than a minute ago"
  def date_in_words(date)
    date.today? ? time_ago_in_words(date) + ' ago' : date.strftime("%b. %d, %Y %H:%M:%S")
  end

  def datepicker_string(date)
    date.try(:strftime, '%m/%d/%Y')
  end

  def loading_icon
    "<i class='fa fa-circle-o-notch fa-spin'></i>".html_safe
  end

  def success_icon
    # "<i class='fa fa-circle-o-notch fa-spin'></i>".html_safe
    "ASDASDASDAD"
  end

end
