require 'spec/spec_helper'

describe Agency do
  before do
    Agency.destroy_all
    @valid_attributes = {
      :name => 'Internal Revenue Service',
      :domain => 'irs.gov',
      :url => 'http://www.irs.gov',
      :phone => '800-555-1234',
      :abbreviation => 'IRS',
      :name_variants => 'External Revenue Service, The Man',
      :toll_free_phone => '800-555-1212',
      :tty_phone => '800-555-1212',
      :twitter_username => 'irs',
      :facebook_username => 'irs',
      :youtube_username => 'irs',
      :flickr_url => 'irs'
    }
  end
  
  context "when creating a new agency" do
    before do
      Agency.create!(@valid_attributes)
    end
    
    it { should validate_presence_of :name }
    it { should validate_presence_of :domain }
    it { should validate_presence_of :url }
    it { should validate_uniqueness_of :domain }
  end
  
  describe "#save" do
    context "when saving with valid attributes" do
      before do
        @agency = Agency.create!(@valid_attributes)
      end
     
      it "should create a bunch of agency queries on save" do
        @agency.agency_queries.should_not be_empty
        @agency.agency_queries.find_by_phrase("irs").should_not be_nil
        @agency.agency_queries.find_by_phrase("internal revenue service").should_not be_nil
        @agency.agency_queries.find_by_phrase("the external revenue service").should_not be_nil
        @agency.agency_queries.find_by_phrase("irs.gov").should_not be_nil
        @agency.agency_queries.find_by_phrase("www.irs.gov").should_not be_nil
        @agency.agency_queries.find_by_phrase("the man").should_not be_nil
      end
    end
    
    context "when saving with a really long flickr url" do
      it "should allow for a long URL for Flickr" do
        agency = Agency.create!(@valid_attributes.merge(:flickr_url => "http://www.flickr.com/photos/reallylonggroupnamethatismorethan50characters"))
        agency.flickr_url.should == "http://www.flickr.com/photos/reallylonggroupnamethatismorethan50characters"
      end
    end
    
    context "when the domain and name are the same value" do
      it "should save without generating an error" do
        @agency = Agency.create!(@valid_attributes.merge(:name => 'Grants.gov', :domain => 'Grants.gov'))
        @agency.id.should_not be_nil
      end
    end
  end
  
  describe "#twitter_profile_link" do
    before do
      @agency = Agency.create!(@valid_attributes)
    end      
    
    context "when the agency has a twitter username" do
      it "should be able to generate a Twitter profile link" do
        @agency.twitter_profile_link.should_not be_nil
      end
    end
    
    context "when the agency has no Twitter username" do
      before do
        @agency.update_attributes(:twitter_username => nil)
      end
      
      it "should return a nil profile link" do
        @agency.twitter_profile_link.should be_nil
      end
    end
  end
  
  describe "#facebook_profile_link" do
    before do
      @agency = Agency.create!(@valid_attributes)
    end
    
    context "when the agency has a facebook username" do
      it "should be able to generate a facebook profile link" do
        @agency.facebook_profile_link.should_not be_nil
      end
    end
    
    context "when the agency has no facebook username" do
      before do
        @agency.update_attributes(:facebook_username => nil)
      end
      
      it "should return a nil profile link" do
        @agency.facebook_profile_link.should be_nil
      end
    end
  end
  
  describe "#youtube_profile_link" do
    before do
      @agency = Agency.create!(@valid_attributes)
    end
    
    context "when the agency has a youtube username" do
      it "should be able to generate a youtube profile link" do
        @agency.youtube_profile_link.should_not be_nil
      end
    end
    
    context "when the agency has no youtube username" do
      before do
        @agency.update_attributes(:youtube_username => nil)
      end
      
      it "should return a nil profile link" do
        @agency.youtube_profile_link.should be_nil
      end
    end
  end
  
  describe "#flickr_profile_link" do
    before do
      @agency = Agency.create!(@valid_attributes)
    end
    
    context "when the agency has a flickr username" do
      it "should be able to generate a flickr profile link" do
        @agency.flickr_profile_link.should_not be_nil
        @agency.flickr_profile_link.should == @agency.flickr_url
      end
    end
    
    context "when the agency has no flickr username" do
      before do
        @agency.update_attributes(:flickr_url => nil)
      end
      
      it "should return a nil profile link" do
        @agency.flickr_profile_link.should be_nil
      end
    end
  end
end 
