class WeatherSpotlight
  attr_accessor :location, :forecast
  
  class << self
    def is_weather_spotlight_query(query)
      !%w{weather forecast}.include?(query.downcase) and query.downcase =~ /^(.*?)\b(weather|forecast)\b(.*?)$/
    end
    
    def parse_query(query)
      location_match = query.downcase.match(/^(.*?)\b(weather|forecast)\b(.*?)$/)
      location_query = location_match.captures.present? ? (location_match.captures[0].present? ? location_match.captures[0].strip : location_match.captures[2].strip) : nil
      location_query.collect{|term| term.strip}.join(' ')
    end
  end
  
  def initialize(location_string)
    @location = Location.find_by_query(location_string)
    if @location
      @forecast = NOAA.forecast(5, @location.lat, @location.lng)
    else
      raise "Location Not Found: #{location_string}"
    end
  end
end