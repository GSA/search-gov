require 'spec_helper'

describe RelatedSearch do

  describe "#related_to" do
    before do
      RelatedQuery.create(:query => 'barack obama', :related_query => 'joe biden', :score => 1.0)
      RelatedQuery.create(:query => 'barack obama', :related_query => 'michelle obama', :score => 0.9)
      RelatedQuery.create(:query => 'thomas jefferson', :related_query => 'john adams', :score => 1.0)
    end
    
    it "should return queries related to the query specified ordered by score descending" do
      related_queries = RelatedSearch.related_to('barack obama')
      related_queries.size.should == 2
      related_queries.first.related_query.should == 'joe biden'
      related_queries.last.related_query.should == 'michelle obama'
    end
    
    it "should return an empty result if there are no related queries to the query specified" do
      RelatedSearch.related_to('margaret thatcher').should be_empty
    end
  end
end
