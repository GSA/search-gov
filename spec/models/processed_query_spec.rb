require 'spec_helper'

describe ProcessedQuery do
  before(:each) do
    @valid_attributes = {
      :query => 'barack obama',
      :affiliate => 'usasearch.gov',
      :day => Date.today,
      :times => 20
    }
  end
  
  should_validate_presence_of :query, :affiliate, :day, :times
  should_validate_numericality_of :times

  it "should create a new instance given valid attributes" do
    ProcessedQuery.create!(@valid_attributes)
  end
  
  describe "#related_to" do
    context "when searching for related queries" do
      before do
        ProcessedQuery.destroy_all
        Sunspot.commit
        ProcessedQuery.reindex
        ProcessedQuery.create!(@valid_attributes.merge(:query => 'barack h. obama'))
        ProcessedQuery.create!(@valid_attributes.merge(:query => 'barack obama'))
        ProcessedQuery.create!(@valid_attributes.merge(:query => 'barak obama'))
        ProcessedQuery.create!(@valid_attributes.merge(:query => 'president barack obama'))
        ProcessedQuery.create!(@valid_attributes.merge(:query => 'michelle obama'))      
        Sunspot.commit
        ProcessedQuery.reindex
      end
    
      it "should return results that are similar to the query specified" do
        related_queries = ProcessedQuery.related_to('barack obama')
        related_queries.total.should == 3
        related_queries.results.first.query.should == 'barack obama'
        related_queries.results.last.query.should == 'barack h. obama'
      end
    end
  end
  
  describe "#load_csv" do
    it "should execute an SQL statement using the filename provided" do
      filename = File.join(RAILS_ROOT, "spec", "fixtures", "csv", "processed_queries.csv")
      ProcessedQuery.load_csv(filename)
      ProcessedQuery.all.size.should == 3
      ProcessedQuery.all.each do |processed_query|
        processed_query.query.should_not be_nil
        processed_query.created_at.should_not be_nil
        processed_query.updated_at.should_not be_nil
      end
      ProcessedQuery.find_by_query('obama').should_not be_nil
    end
  end
end
