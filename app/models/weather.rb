class Weather
  CACHE_KEY = 'weather'

  def self.temperature_f
    fetch[:temperature]
  end

  def self.icon
    fetch[:icon]
  end

  def self.sun_set_time
    fetch[:sun][:set]
  end

  def self.update
    clear
    fetch
  end

  private
    def self.clear
      Rails.cache.delete(CACHE_KEY)
    end

    def self.fetch
      Rails.cache.write(CACHE_KEY, Barometer.new('Boston').measure.current) if Rails.cache.read(CACHE_KEY).nil?

      Rails.cache.read(CACHE_KEY)
    end
end