class Location < ActiveRecord::Base
  validates_presence_of :state, :city, :zip_code, :population, :lat, :lng
  
  class << self
    # parse locations from file http://www.census.gov/tiger/tms/gazetteer/zips.txt (described http://www.census.gov/tiger/tms/gazetteer/zip90r.txt)
    def parse(filename)
      FasterCSV.foreach(filename) do |row|
        Location.create(:zip_code => row[1], :state => row[2], :city => row[3].titleize, :population => row[6], :lat => row[5].to_d, :lng => -1.0 * row[4].to_d)
      end
    end
  end
end
