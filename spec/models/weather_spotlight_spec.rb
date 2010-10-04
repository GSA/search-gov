require "#{File.dirname(__FILE__)}/../spec_helper"

describe WeatherSpotlight do
  before do
    Location.create(:zip_code => 21209, :state => 'MD', :city => 'Baltimore', :population => 20000, :lat => 39.0494, :lng => -76.4567)
  end
  
  describe "#new" do
    context 'zip code searches' do
      before do
        @query = 'weather 21209'
      end
      
      it "should set the query value" do
        WeatherSpotlight.new(@query).query.should == @query
      end
    
      it "should set the location based on the zip code in the query" do
        weather_spotlight = WeatherSpotlight.new(@query)
        weather_spotlight.location.state.should == 'MD'
        weather_spotlight.location.city.should == 'Baltimore'
      end
    
      it "should retrieve 5 day forecast" do
        WeatherSpotlight.new(@query).forecast.length.should == 5
      end
    
      context "when the zip code is invalid" do
        before do
          @query = 'weather 21208'
        end
        
        it "should raise an exception" do
          lambda {WeatherSpotlight.new(@query)}.should raise_error(RuntimeError, 'Location Not Found: 21208')
        end
      end
    end
  end
end