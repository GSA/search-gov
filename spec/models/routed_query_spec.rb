require 'spec_helper'

describe RoutedQuery do
  fixtures :affiliates, :routed_queries

  describe 'Creating new instance' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:valid_attributes) do
      {
        description: 'Some desc',
        url: 'http://www.gov.gov/url.html',
        routed_query_keywords_attributes: { '0' => { 'keyword' => 'some keyword phrase' } }
      }
    end

    it { should belong_to :affiliate }
    it { should have_many(:routed_query_keywords).dependent(:destroy) }
    it { should validate_presence_of :description }
    it { should validate_uniqueness_of(:description).scoped_to(:affiliate_id) }

    it { should validate_presence_of :affiliate }
    it { should validate_format_of(:url).with(URI.regexp) }

    it 'should create a new instance given valid attributes' do
      affiliate.routed_queries.create!(valid_attributes)
    end
  end

  describe '#label' do
    it 'returns a label containing the url and description' do
      routed_queries(:unclaimed_money).label.should == 'http://www.usa.gov/unclaimed_money: Everybody wants it'
    end
  end

  describe '#dup' do
    subject(:original_instance) { routed_queries(:unclaimed_money) }
    include_examples 'site dupable'
  end
end
