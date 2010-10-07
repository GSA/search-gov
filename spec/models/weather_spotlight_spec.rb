require "#{File.dirname(__FILE__)}/../spec_helper"

describe WeatherSpotlight do
  before(:all) do
    Location.delete_all
    Location.count.should == 0
    @popular_location = Location.create(:zip_code => 21209, :state => 'MD', :city => 'Baltimore', :population => 20000, :lat => 39.0494, :lng => -76.4567)
    Location.create(:zip_code => 21215, :state => 'MD', :city => 'Baltimore', :population => 19000, :lat => 39.0494, :lng => -76.4567)
    Location.create(:zip_code => 21216, :state => 'NY', :city => 'Baltimore', :population => 1000, :lat => 39.0494, :lng => -76.4567)
     @san_fran = Location.create(:zip_code => 11111, :state => 'CA', :city => 'San Francisco', :population => 1000, :lat => 39.0494, :lng => -76.4567)
    Location.create(:zip_code => 11112, :state => 'CA', :city => 'San Francisco', :population => 999, :lat => 39.0494, :lng => -76.4567)
    @weather_query = '21209'
  end
  
  describe "#new" do
    it "should retrieve 5 day forecast" do
      WeatherSpotlight.new(@weather_query).forecast.length.should == 5
    end
    
    context "zip code searches" do
      before do
        @query = '21209'
      end
    
      it "should set the location based on the zip code in the query" do
        WeatherSpotlight.new(@query).location.should == @popular_location
      end
        
      context "when the zip code is not in the database" do
        before do
          @query = '21208'
        end
        
        it "should raise an exception" do
          lambda {WeatherSpotlight.new(@query)}.should raise_error(RuntimeError, 'Location Not Found: 21208')
        end
      end
    end
    
    context "city/state searches" do
      context "when the query is in the form of 'city, ST'" do
        before do
          @city_state_query = 'baltimore, md'
        end
        
        it "should set the location to the matching location with the highest population" do
          WeatherSpotlight.new(@city_state_query).location.should == @popular_location
        end
      
        context "when the query is not found" do
          before do
            @city_state_query = "baltimore, tx"
          end
        
          it "should raise an exception that the Location was not found" do
            lambda {WeatherSpotlight.new(@city_state_query).should raise_error(RuntimeError, 'Location Not Found: baltimore, tx')}
          end
        end
      end
      
      context "when the query is in the form of 'city ST'" do
        before do
          @city_state_query = 'san francisco ca'
        end
        
        it "should set the location to the matching location with the highest population" do
          WeatherSpotlight.new(@city_state_query).location.should == @san_fran
        end
        
        context "when the query is not found" do
          before do
            @city_state_query = 'san diego ca'
          end
          
          it "should raise an exception that the Location was not found" do
            lambda {WeatherSpotlight.new(@city_state_query).should raise_error(RuntimeError, 'Location Not Found: san diego ca')}
          end
        end
      end
      
      context "when the query is in the form of 'city'" do
        before do
          @city_query = 'baltimore'
        end
        
        it "should set the location to the matching Location with the highest population" do
          WeatherSpotlight.new(@city_query).location.should == @popular_location
        end
        
        context "when the query is not found" do
          before do
            @city_query = 'boston'
          end
          
          it "should raise an exception that the Location was not found" do
            lambda {WeatherSpotlight.new(@city_query).should raise_error(RuntimeError, 'Location Not Found: boston')}
          end
        end
      end
    end
  end
end