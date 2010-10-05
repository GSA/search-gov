class WeatherSpotlight
  attr_accessor :query, :location, :forecast
  
  def initialize(query)
    location_match = query.downcase.match(/^(.*?)\b(weather|forecast)\b(.*?)$/)
    location_query = location_match.captures.present? ? (location_match.captures[0].present? ? location_match.captures[0].strip : location_match.captures[2].strip) : nil
    if location_query
      @query = query
      if location_query =~ /\d{5}/
        @location = Location.find_by_zip_code(location_query)
      end
      if location_query.include?(',')
        city_state = location_query.split(',')
        @location = Location.find_by_state_and_city(city_state.last.strip, city_state.first, :order => 'population desc')
      else
        city_state = location_query.split
        if city_state.last.length == 2
          @location = Location.find_by_state_and_city(city_state.last.strip, city_state[0..-2].join(' '), :order => 'population desc')
        else
          @location = Location.find_by_city(city_state.collect{|term| term.strip}.join(' '), :order => 'population desc')
        end
      end unless @location
      if @location
        @forecast = NOAA.forecast(5, @location.lat, @location.lng)
      else
        raise "Location Not Found: #{location_query}"
      end
    end
  end  
end