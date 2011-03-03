require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
      :flickr_username => 'irs'
    }
    @agency = Agency.create!(@valid_attributes)
  end
  
  should_validate_presence_of :name, :domain, :url
  should_validate_uniqueness_of :domain
  
  describe "#save" do
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
  
  describe "#twitter_profile_link" do
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
    context "when the agency has a flickr username" do
      it "should be able to generate a flickr profile link" do
        @agency.flickr_profile_link.should_not be_nil
      end
    end
    
    context "when the agency has no flickr username" do
      before do
        @agency.update_attributes(:flickr_username => nil)
      end
      
      it "should return a nil profile link" do
        @agency.flickr_profile_link.should be_nil
      end
    end
  end
end 