require 'spec_helper'

describe RoutedQuery do
  fixtures :affiliates, :routed_queries

  describe "Creating new instance" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:valid_attributes) { { description: "Some desc", url: "http://www.gov.gov/url.html" } }

    it { should belong_to :affiliate }
    it { should have_many(:routed_query_keywords).dependent(:destroy) }
    it { should validate_presence_of :affiliate }

    it "should create a new instance given valid attributes" do
      affiliate.routed_queries.create!(valid_attributes)
    end

  end

  describe "label" do
    it 'returns a label containing the url and description' do
      routed_queries(:unclaimed_money).label.should == "http://www.usa.gov/unclaimed_money: Everybody wants it"
    end
  end
end
