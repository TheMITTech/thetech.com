namespace :cache do
  desc "Clear the weather cache and regenerates it. "
  task update_weather: :environment do
    Weather.update
    Logger.new(File.join(Rails.root, 'log/rake.log')).info("Weather data updated at #{Time.now.to_s}. ")
  end

end
