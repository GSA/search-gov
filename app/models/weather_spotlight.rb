class WeatherSpotlight
  attr_accessor :query, :location, :forecast
  
  def initialize(query)
    location = query.match(/weather (\d{5})/).captures[0]
    if location
      @query = query
      @location = Location.find_by_zip_code(location)
      if @location
        @forecast = NOAA.forecast(5, @location.lat, @location.lng)
      else
        raise "Location Not Found: #{location}"
      end
    end
  end  
end