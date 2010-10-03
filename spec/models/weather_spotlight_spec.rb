require "#{File.dirname(__FILE__)}/../spec_helper"

describe WeatherSpotlight do
  before do
    Location.create(:zip_code => 21209, :state => 'MD', :city => 'Baltimore', :population => 20000, :lat => 39.0494, :lng => -76.4567)
  end
  
  describe "#new" do
    it "should set the query value" do
      WeatherSpotlight.new('weather 21209').query.should == 'weather 21209'
    end
    
    it "should set the location based on the zip code in the query" do
      weather_spotlight = WeatherSpotlight.new('weather 21209')
      weather_spotlight.location.state.should == 'MD'
      weather_spotlight.location.city.should == 'Baltimore'
    end
    
    it "should retrieve 5 day forecast" do
      WeatherSpotlight.new('weather 21209').forecast.length.should == 5
    end
  end
end