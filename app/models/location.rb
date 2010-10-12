class Location < ActiveRecord::Base
  validates_presence_of :state, :city, :zip_code, :population, :lat, :lng
  
  class << self
    # parse locations from file http://www.census.gov/tiger/tms/gazetteer/zips.txt (described http://www.census.gov/tiger/tms/gazetteer/zip90r.txt)
    def load_from_census_data(filename)
      FasterCSV.foreach(filename) do |row|
        Location.create(:zip_code => row[1], :state => row[2], :city => row[3].titleize, :population => row[6], :lat => row[5].to_d, :lng => -1.0 * row[4].to_d)
      end
    end
    
    def load_from_geonames_data(filename)
      FasterCSV.foreach(filename, :col_sep => "\t") do |row|
        Location.create(:zip_code => row[1], :state => row[4], :city => row[2], :population => 0, :lat => row[9], :lng => row[10])
      end
    end
    
    def find_by_query(location_query)
      if location_query =~ /\d{5}/
        location = Location.find_by_zip_code(location_query)
      end
      unless location
        if location_query.include?(',')
          city_state = location_query.split(',')
          location = Location.find_by_state_and_city(city_state.last.strip, city_state.first, :order => 'population desc')
        else
          city_state = location_query.split
          if city_state.last.length == 2
            location = Location.find_by_state_and_city(city_state.last.strip, city_state[0..-2].join(' '), :order => 'population desc')
          else
            location = Location.find_by_city(city_state.collect{|term| term.strip}.join(' '), :order => 'population desc')
          end
        end
      end
      location
    end
  end
end