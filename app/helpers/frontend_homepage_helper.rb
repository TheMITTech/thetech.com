module FrontendHomepageHelper
  def wicon_name(icon, sun_set)
    if Time.now < sun_set # day
      case icon
      when 'fog'
        "fog"
      when 'hazy'
        "dust"
      when 'mostlycloudly'
        "cloudy"
      when 'mostlysunny'
        "day-sunny-overcast"
      when 'partlycloudy', 'partlysunny'
        "day-cloudy"
      when 'rain'
        "rain"
      when 'sleet'
        "sleet"
      when 'flurries', 'snow'
        "snow"
      when 'clear', 'sunny'
        "day-sunny"
      when 'tstorms'
        "thunderstorm"
      when 'cloudy'
        "cloudy"
      else
        ""
      end
    else # night
      case icon
      when 'fog'
        "night-fog"
      when 'hazy'
        "dust"
      when 'mostlycloudly'
        "cloudy"
      when 'mostlysunny', 'partlycloudy', 'partlysunny'
        "night-cloudy"
      when 'rain'
        "night-rain"
      when 'sleet'
        "night-sleet"
      when 'flurries', 'snow'
        "night-snow"
      when 'clear'
        "night-clear"
      when 'tstorms'
        "night-thunderstorm"
      when 'cloudy'
        "night-cloudy"
      else
        ""
      end
    end
  end
end
