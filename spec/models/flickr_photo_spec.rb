require 'spec/spec_helper'

describe FlickrPhoto do
  fixtures :affiliates
  
  before do
    @valid_attributes = {
      :flickr_id => '12345678'
    }
    @affiliate = affiliates(:basic_affiliate)
    @flickr_profile = FlickrProfile.create(:url => 'http://flickr.com/photos/USAgency', :affiliate => @affiliate, :profile_type => 'user', :profile_id => '12345')
  end
  
  it { should validate_presence_of :flickr_id }
  it { should validate_presence_of :flickr_profile }
  
  it "should create a new instance given valid attributes" do    
    FlickrPhoto.create!(@valid_attributes.merge(:flickr_profile => FlickrProfile.create))
    should validate_uniqueness_of(:flickr_id).scoped_to(:flickr_profile_id)
  end
  
  describe "#search_for" do
    before do
      FlickrPhoto.destroy_all
      FlickrPhoto.create(:flickr_id => 1, :flickr_profile => @flickr_profile, :title => 'A picture of Barack Obama', :description => 'Barack Obama playing with his dog at the White House.', :tags => 'barackobama,barack obama,dog,white house', :date_taken => Time.now - 3.days)
      FlickrPhoto.create(:flickr_id => 2, :flickr_profile => @flickr_profile, :title => 'Barack Obama and Joe Biden in Air Force One', :description => 'President Barack Obama and Vice President Joe Biden boarding Air Force One for a quick trip somewhere.', :tags => "joe biden vice president barack obama", :date_taken => Time.now - 2.days)
      FlickrPhoto.create(:flickr_id => 3, :flickr_profile => @flickr_profile, :title => 'Barack and Michelle Obama', :description => 'President Barack Obama and First Lady Michelle Obama attend a state dinner at the White House', :tags => "barack obama,michelle,whitehouse", :date_taken => Time.now - 4.days)
      FlickrPhoto.create(:flickr_id => 4, :flickr_profile => @flickr_profile, :title => 'Barack Obama Throws First Pitch', :description => 'President Barack Obama throws out the first pitch at a Washington Nationals baseball game.', :date_taken => Time.now - 5.days)
      FlickrPhoto.create(:flickr_id => 5, :flickr_profile => @flickr_profile, :title => "President Obama walks his daughters to school", :description => '', :tags => 'barack obama,sasha,malia')
      FlickrPhoto.create(:flickr_id => 6, :flickr_profile => @flickr_profile, :title => 'POTUS gets in car.', :description => 'Barack Obama gets into his super protected car.', :tags => "car,batman", :date_taken => Time.now - 14.days)
      FlickrPhoto.reindex
    end
    
    context "when searching with default page and per_page" do
      before do
        @search = FlickrPhoto.search_for("obama", @affiliate)
      end
      
      it "should default to the first page" do
        @search.results.first_page?.should be_true
      end
      
      it "should return five results" do
        @search.results.size.should == 5
      end
    end
    
    context "when searching with page and per_page parameters" do
      before do
        @search = FlickrPhoto.search_for("obama", @affiliate, 2, 2)
      end
      
      it "should return the proper page" do
        @search.results.first_page?.should be_false
      end
      
      it "should page the results accordingly" do
        @search.results.size.should == 2
      end
    end
    
    context "when a blank search is entered" do
      before do
        @search = FlickrPhoto.search_for("", @affiliate)
      end
      
      it "should return nil" do
        @search.should be_nil
      end
    end
    
    context "when searching on a matching tag" do
      before do
        @search = FlickrPhoto.search_for("batman", @affiliate)
      end
      
      it "should find matching photos" do
        @search.total.should == 1
        @search.results.first.title.should == "POTUS gets in car."
      end
    end
  end  
end