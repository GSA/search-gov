# frozen_string_literal: true

require 'spec_helper'

describe RoutedQuery do
  fixtures :affiliates, :routed_queries

  subject(:routed_query) { described_class.new }

  describe 'Creating new instance' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:valid_attributes) do
      {
        description: 'Some desc',
        url: 'http://www.gov.gov/url.html',
        routed_query_keywords_attributes: {
          '0' => { 'keyword' => 'some keyword phrase' }
        }
      }
    end

    it { is_expected.to belong_to :affiliate }

    it 'has keywords' do
      expect(routed_query).to have_many(:routed_query_keywords).
        dependent(:destroy).
        inverse_of(:routed_query)
    end

    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_uniqueness_of(:description).scoped_to(:affiliate_id) }
    it { is_expected.to validate_presence_of :affiliate }
    it { is_expected.to allow_value('http://www.foo.com').for(:url) }
    it { is_expected.not_to allow_value('www.foo.com').for(:url) }
    it { is_expected.not_to allow_value('data:text/;&Tab.base64').for(:url) }

    it 'creates a new instance given valid attributes' do
      affiliate.routed_queries.create!(valid_attributes)
    end

    context 'when a keyword is duplicated' do
      let(:dup_attributes) do
        valid_attributes.merge(
          {
            routed_query_keywords_attributes:
            {
              '0' => { 'keyword' => 'some keyword phrase' },
              '1' => { 'keyword' => 'Some Keyword Phrase' }
            }
          }
        )
      end

      let(:expected_errors) do
        'The following keyword has been duplicated: \'some keyword phrase\'. ' \
          'Each keyword is case-insensitive and should be added only once.'
      end

      it 'rejects the save of the keywords' do
        rq = affiliate.routed_queries.build(dup_attributes)
        expect(rq.valid?).to be false
        expect(rq.errors[:routed_query_keywords]).to include(expected_errors)
      end
    end

    context 'when multiple keywords are duplicated' do
      let(:dup_attributes) do
        valid_attributes.merge(
          {
            routed_query_keywords_attributes:
            {
              '0' => { 'keyword' => 'some keyword phrase' },
              '1' => { 'keyword' => 'Some Keyword Phrase' },
              '2' => { 'keyword' => 'some other keyword phrase' },
              '3' => { 'keyword' => 'Some Other Keyword Phrase' }
            }
          }
        )
      end

      let(:expected_errors) do
        'The following keywords have been duplicated: \'some keyword phrase\', ' \
          '\'some other keyword phrase\'. ' \
          'Each keyword is case-insensitive and should be added only once.'
      end

      it 'rejects the save of the keywords' do
        rq = affiliate.routed_queries.build(dup_attributes)
        expect(rq.valid?).to be false
        expect(rq.errors[:routed_query_keywords]).to include(expected_errors)
      end
    end
  end

  describe '#label' do
    it 'returns a label containing the url and description' do
      expect(routed_queries(:unclaimed_money).label).
        to eq('https://www.usa.gov/unclaimed_money: Everybody wants it')
    end
  end

  describe '#dup' do
    subject(:original_instance) { routed_queries(:unclaimed_money) }

    include_examples 'site dupable'
  end
end
