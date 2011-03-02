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
      :name_variants => 'External Revenue Service, The Man'
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
end