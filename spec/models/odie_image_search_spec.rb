require 'spec_helper'

describe OdieImageSearch do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:basic_affiliate)
    flickr_profile = FlickrProfile.create(:url => 'http://flickr.com/photos/USAgency', :affiliate => @affiliate, :profile_type => 'user', :profile_id => '12345')
    FlickrPhoto.delete_all
    ElasticFlickrPhoto.recreate_index
    FlickrPhoto.create!(:flickr_id => 5, :flickr_profile => flickr_profile, :title => 'President Obama walks the Obama daughters to school', :description => '', :tags => 'barack obama,sasha,malia')
    FlickrPhoto.create!(:flickr_id => 6, :flickr_profile => flickr_profile, :title => 'POTUS gets in car.', :description => 'Barack Obama gets into his super protected car.', :tags => "car,batman", :date_taken => Time.now - 14.days)
    FlickrPhoto.create!(:flickr_id => 7, :flickr_profile => flickr_profile, :title => 'irrelevant photo', :description => 'irrelevant', :tags => "car,batman", :date_taken => Time.now - 14.days)
    ElasticFlickrPhoto.commit
  end

  describe ".search" do
    it "should find relevant Flickr photos" do
      image_search = OdieImageSearch.new(:query => 'obama', :affiliate => @affiliate)
      image_search.run
      image_search.results.first["title"].should == 'President Obama walks the Obama daughters to school'
      image_search.results.last["title"].should == 'POTUS gets in car.'
      image_search.total.should == 2
    end
  end

  describe ".cache_key" do
    it "should output a key based on the query, affiliate id, and page parameters" do
      OdieImageSearch.new(:query => 'element', :affiliate => @affiliate, :page => 4).cache_key.should == "odie_image:element:#{@affiliate.id}:4:10"
    end
  end

end