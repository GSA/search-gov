require 'spec_helper'

describe RoutedQueryKeyword do
  fixtures :affiliates, :routed_queries, :routed_query_keywords

  describe 'Creating new instance' do
    let(:routed_query) { routed_queries(:unclaimed_money) }

    it { should belong_to :routed_query }
    it { should validate_presence_of :routed_query }
    it { should validate_presence_of :keyword }
    it { should validate_uniqueness_of(:keyword).scoped_to(:routed_query_id) }

    it 'should create a new instance given valid attributes' do
      routed_query.routed_query_keywords.create!(keyword: 'route me')
    end

    it 'should downcase, squish and strip whitespace from keyword before inserting in DB' do
      keyword = ' leading          and trailing whitespaces AND CAPITALS'
      rqk = routed_query.routed_query_keywords.create!(keyword: keyword)
      rqk.keyword.should == 'leading and trailing whitespaces and capitals'
    end

    it 'should not allow the same keyword to be reused within a single affiliate' do
      routed_queries(:unclaimed_money).routed_query_keywords.create!(keyword: 'route me')
      rqk = routed_queries(:moar_unclaimed_money).routed_query_keywords.build(keyword: 'route me')
      rqk.should_not be_valid
      rqk.errors[:keyword].should eq(["The keyword 'route me' is already in use for a different routed query"])
    end
  end

  describe 'label' do
    it 'returns the keyword' do
      routed_query_keywords(:one).label.should == 'unclaimed money owed to me'
    end
  end
end
