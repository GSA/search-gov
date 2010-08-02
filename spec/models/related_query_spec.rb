require 'spec_helper'

describe RelatedQuery do
  before(:each) do
    @valid_attributes = {
     :query => "barack obama",
     :related_query => "joe biden",
     :score => 1.0
    }
  end
  
  should_validate_presence_of :query, :related_query, :score
  should_validate_numericality_of :score

  it "should create a new instance given valid attributes" do
    RelatedQuery.create!(@valid_attributes)
  end
  
  it "should downcase the query and related query before saving" do
    related_query = RelatedQuery.create(:query => "Barack Obama", :related_query => "Joe Biden", :score => 1.0)
    related_query.query.should == "barack obama"
    related_query.related_query.should == "joe biden"
  end
  
  describe "#search_for" do
    before do
      RelatedQuery.create(:query => 'related1', :related_query => 'related2', :score => 1.0)
      RelatedQuery.create(:query => 'related3', :related_query => 'related4', :score => 0.9)
      @query = "Related1"
    end
    
    it "should find all the related queries for the query specified, regardless of case" do
      RelatedQuery.should_receive(:find_all_by_query).with(@query.downcase, :order => "score desc", :limit => 5).and_return []
      RelatedQuery.search_for("related1")
    end
  end
  
  describe "#load_json" do
    context "when loading related searches as JSON" do
      before do
        @filename = File.join(RAILS_ROOT + "/spec/fixtures/json/related_queries.json")
      end
  
      it "should create a new related search record for each of the pairs listed on each line, associated with the key" do
        RelatedQuery.should_receive(:create).exactly(50).times
        RelatedQuery.load_json(@filename)
      end
    end
  end
end
