require 'spec_helper'

describe RelatedSearch do

  describe "#related_to" do
    before do
      RelatedQuery.create(:query => 'barack obama', :related_query => 'joe biden', :score => 1.0)
      RelatedQuery.create(:query => 'barack obama', :related_query => 'michelle obama', :score => 0.9)
      RelatedQuery.create(:query => 'thomas jefferson', :related_query => 'john adams', :score => 1.0)
    end
    
    it "should return queries related to the query specified ordered by score descending" do
      related_search = RelatedSearch.related_to('barack obama')
      related_search.size.should == 2
      related_search.first.should == 'joe biden'
      related_search.last.should == 'michelle obama'
    end
    
    it "should return an empty result if there are no related queries to the query specified" do
      RelatedSearch.related_to('margaret thatcher').should be_empty
    end
    
    context "when ProcessedQueries that are related to the query are present" do
      before do
        ProcessedQuery.create(:query => 'barack hussein obama', :times => 100, :day => Date.yesterday, :affiliate => 'usasearch.gov')
        ProcessedQuery.create(:query => 'barack h. obama', :times => 100, :day => Date.yesterday, :affiliate => 'usasearch.gov')
        ProcessedQuery.create(:query => 'president barack obama', :times => 100, :day => Date.yesterday, :affiliate => 'usasearch.gov')
        ProcessedQuery.create(:query => 'barak obama', :times => 100, :day => Date.yesterday, :affiliate => 'usasearch.gov')
        Sunspot.commit
        ProcessedQuery.reindex
      end
      
      it "should backfill the related search results with matching ProcessedQuery values, so that a total of values are returned" do
        related_search = RelatedSearch.related_to('barack obama')
        related_search.size.should == 5
        related_search.first.should == 'joe biden'
        related_search[1].should == 'michelle obama'
        related_search[2].should == 'president barack obama'
        related_search[3].should == 'barack hussein obama'
        related_search.last.should == 'barack h. obama'
      end
      
      it "should return an empty array if nothing matches" do
        RelatedSearch.related_to('margaret thatcher').should be_empty
      end
      
      context "when there are no RelatedQuery records" do
        before do
          RelatedQuery.destroy_all
        end
        
        it "should return up to 5 ProcessedQuery results" do
          related_search = RelatedSearch.related_to('barack obama')
          related_search.size.should == 3
        end
      end
    end
  end
end
