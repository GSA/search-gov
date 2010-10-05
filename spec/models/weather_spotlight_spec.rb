require "#{File.dirname(__FILE__)}/../spec_helper"

describe WeatherSpotlight do
  before do
    @popular_location = Location.create(:zip_code => 21209, :state => 'MD', :city => 'Baltimore', :population => 20000, :lat => 39.0494, :lng => -76.4567)
    Location.create(:zip_code => 21215, :state => 'MD', :city => 'Baltimore', :population => 19000, :lat => 39.0494, :lng => -76.4567)
    Location.create(:zip_code => 21216, :state => 'NY', :city => 'Baltimore', :population => 1000, :lat => 39.0494, :lng => -76.4567)
     @san_fran = Location.create(:zip_code => 11111, :state => 'CA', :city => 'San Francisco', :population => 1000, :lat => 39.0494, :lng => -76.4567)
    Location.create(:zip_code => 11112, :state => 'CA', :city => 'San Francisco', :population => 999, :lat => 39.0494, :lng => -76.4567)
    @weather_query = 'weather 21209'
  end
  
  describe "#new" do
    
    it "should set the query value" do
      WeatherSpotlight.new(@weather_query).query.should == @weather_query
    end
    
    it "should retrieve 5 day forecast" do
      WeatherSpotlight.new(@weather_query).forecast.length.should == 5
    end
    
    it "should ignore case" do
      WeatherSpotlight.new('WEatheR 21209').location.should == @popular_location
    end

    context "zip code searches" do
      before do
        @query = 'weather 21209'
      end
    
      it "should set the location based on the zip code in the query" do
        WeatherSpotlight.new(@query).location.should == @popular_location
      end
        
      context "when the zip code is not in the database" do
        before do
          @query = 'weather 21208'
        end
        
        it "should raise an exception" do
          lambda {WeatherSpotlight.new(@query)}.should raise_error(RuntimeError, 'Location Not Found: 21208')
        end
      end
    end
    
    context "city/state searches" do
      context "when the query is in the form of 'city, ST'" do
        before do
          @city_state_query_1 = 'weather baltimore, md'
          @city_state_query_2 = 'baltimore, md forecast'
        end
        
        it "should set the location to the matching location with the highest population" do
          WeatherSpotlight.new(@city_state_query_1).location.should == @popular_location
          WeatherSpotlight.new(@city_state_query_2).location.should == @popular_location
        end
      
        context "when the query is not found" do
          before do
            @city_state_query = "weather baltimore, tx"
          end
        
          it "should raise an exception that the Location was not found" do
            lambda {WeatherSpotlight.new(@city_state_query).should raise_error(RuntimeError, 'Location Not Found: baltimore, tx')}
          end
        end
      end
      
      context "when the query is in the form of 'city ST'" do
        before do
          @city_state_query_1 = 'weather san francisco ca'
          @city_state_query_2 = 'san francisco ca forecast'
        end
        
        it "should set the location to the matching location with the highest population" do
          WeatherSpotlight.new(@city_state_query_1).location.should == @san_fran
          WeatherSpotlight.new(@city_state_query_2).location.should == @san_fran
        end
        
        context "when the query is not found" do
          before do
            @city_state_query = 'weather san diego ca'
          end
          
          it "should raise an exception that the Location was not found" do
            lambda {WeatherSpotlight.new(@city_state_query).should raise_error(RuntimeError, 'Location Not Found: san diego ca')}
          end
        end
      end
      
      context "when the query is in the form of 'city'" do
        before do
          @city_query_1 = 'baltimore weather'
          @city_query_2 = 'forecast san francisco'
        end
        
        it "should set the location to the matching Location with the highest population" do
          WeatherSpotlight.new(@city_query_1).location.should == @popular_location
          WeatherSpotlight.new(@city_query_2).location.should == @san_fran
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