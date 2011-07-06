require 'spec/spec_helper'

describe Agency do
  before do
    Agency.destroy_all
    @valid_attributes = {
      :name => 'Internal Revenue Service',
      :domain => 'irs.gov',
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
  
  describe "#has_phone_number" do
    before do
      @agency = Agency.create!(@valid_attributes)
    end
    
    context "when all phones are present" do
      it "should return true" do
        @agency.has_phone_number?.should be_true
      end
    end
    
    context "when no phone number fields are present" do
      before do
        @agency.reload
        @agency.phone = nil
        @agency.toll_free_phone = nil
        @agency.tty_phone = nil
      end
      
      it "should return false" do
        @agency.has_phone_number?.should be_false
      end
    end
    
    context "when only phone is present" do
      before do
        @agency.reload
        @agency.toll_free_phone = nil
        @agency.tty_phone = nil
      end
      
      it "should return true" do
        @agency.has_phone_number?.should be_true
      end
    end

    context "when only a toll free phone is present" do
      before do
        @agency.reload
        @agency.phone = nil
        @agency.tty_phone = nil
      end
      
      it "should return true" do
        @agency.has_phone_number?.should be_true
      end
    end

    context "when only tty phone is present" do
      before do
        @agency.reload
        @agency.phone = nil
        @agency.toll_free_phone = nil
      end
      
      it "should return true" do
        @agency.has_phone_number?.should be_true
      end
    end
  end

  describe "#displayable_popular_urls" do
      before do
        @pop_agency = Agency.create!(@valid_attributes)
        agency_base_url = "http://www.#{@valid_attributes[:domain]}/"
        @sample_pop_page_data = [
            ["", "Welcome to the IRS", 1],
            ["forms/index.html", "IRS Forms", 2],
            ["forms/1040.pdf", "1040NR", 4],
            ["forms/1040-nr.pdf", "1040NR", 6],
            ["forms/1041-nr.pdf", "1041NR, the form that nobody ever ever ever ever uses to file anything they would not want to be seen posted on a sandwich board in downtown NY", 3],
            ["forms/1041.pdf", "1041", 5]
        ]
        @sample_pop_page_data.each_with_index { |values, rank|
          @pop_agency.agency_popular_urls.create!( :url => agency_base_url +values[0], :title => values[1], :rank => values[2])
        }
      end

      it "should have six displayable popular pages" do
        @pop_agency.instance_variable_defined?(:@cached_displayable_popular_urls).should be_false
        pop_pages = @pop_agency.displayable_popular_urls
        pop_pages[0..4].collect { |pp| pp.rank }.should eql((1.upto(5)).collect {|n| n})
        pop_pages.size.should eql( @sample_pop_page_data.size )
        @pop_agency.instance_variable_defined?(:@cached_displayable_popular_urls).should be_true
        @pop_agency.displayable_popular_urls.should be pop_pages
      end

      after do
        @pop_agency.destroy
      end
  end

end 
