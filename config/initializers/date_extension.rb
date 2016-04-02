class Date
  def to_datetime_with_time_zone
    Time.zone.local_to_utc(self.to_datetime).in_time_zone
  end
end

class Time
  def to_datetime_with_time_zone
    Time.zone.local_to_utc(self.to_datetime).in_time_zone
  end
end