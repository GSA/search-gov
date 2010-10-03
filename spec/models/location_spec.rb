require "#{File.dirname(__FILE__)}/../spec_helper"

describe Location do
  before do
    @valid_attributes = {
      :zip_code => 21209,
      :state => 'MD',
      :city => 'Baltimore',
      :population => 20673,
      :lat => 39.3716,
      :lng => -76.6744
    }
  end
  
  should_validate_presence_of :zip_code, :state, :city, :population, :lat, :lng
  
  it "should create a Location given valid attributes" do
    Location.create!(@valid_attributes)
  end
  
  describe "#parse" do
    before do
      @filename = File.join(RAILS_ROOT, "spec", "fixtures", "txt", "zips.txt")    
    end
    
    it "should parse the file and create Locations for each of the lines, titleizing the city and multiplying the longitude by -1" do
      Location.parse(@filename)
      Location.count.should == 13
      Location.find_all_by_city('Baltimore').size.should == 10
      Location.all.each do |location|
        location.lng.should < 0
      end
    end
  end
end