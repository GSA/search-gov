require 'spec_helper'

describe RoutedQueryKeyword do
  fixtures :affiliates, :routed_queries, :routed_query_keywords
  let(:routed_query) { routed_queries(:unclaimed_money) }

  describe 'Creating new instance' do
    it { is_expected.to belong_to(:routed_query).inverse_of(:routed_query_keywords) }
    it { is_expected.to validate_presence_of :routed_query }
    it { is_expected.to validate_presence_of :keyword }
    it { is_expected.to validate_uniqueness_of(:keyword).scoped_to(:routed_query_id).case_insensitive }

    it 'should create a new instance given valid attributes' do
      routed_query.routed_query_keywords.create!(keyword: 'route me')
    end

    it 'should downcase, squish and strip whitespace from keyword before inserting in DB' do
      keyword = ' leading          and trailing whitespaces AND CAPITALS'
      rqk = routed_query.routed_query_keywords.create!(keyword: keyword)
      expect(rqk.keyword).to eq('leading and trailing whitespaces and capitals')
    end

    it 'should not allow the same keyword to be reused within a single affiliate' do
      routed_queries(:unclaimed_money).routed_query_keywords.create!(keyword: 'route me')
      rqk = routed_queries(:moar_unclaimed_money).routed_query_keywords.build(keyword: 'route me')
      expect(rqk).not_to be_valid
      expect(rqk.errors[:keyword]).to eq(["The keyword 'route me' is already in use for a different routed query"])
    end

    it 'creates a matching SaytSuggestion' do
      routed_query.routed_query_keywords.create!(keyword: 'route me')
      sayt_suggestion = SaytSuggestion.find_by_affiliate_id_and_phrase_and_is_protected(routed_query.affiliate.id, 'route me', true)
      expect(sayt_suggestion).to be_present
    end
  end

  describe 'Updating a keyword' do
    before do
      keyword = routed_query.routed_query_keywords.create!(keyword: 'initial keyword')
      keyword.update_attribute(:keyword, 'updated keyword')
    end

    it 'updates the matching SaytSuggestion' do
      sayt_suggestion = SaytSuggestion.find_by_affiliate_id_and_phrase_and_is_protected(routed_query.affiliate.id, 'updated keyword', true)
      expect(sayt_suggestion).to be_present
    end
  end

  describe 'deleting a keyword' do
    before do
      routed_query.routed_query_keywords.create!(keyword: 'some keyword')
      sayt_suggestion = SaytSuggestion.find_by_affiliate_id_and_phrase_and_is_protected(routed_query.affiliate.id, 'some keyword', true)
      expect(sayt_suggestion).to be_present
    end

    it 'deletes the matching SaytSuggestion' do
      RoutedQueryKeyword.last.destroy
      sayt_suggestion = SaytSuggestion.find_by_affiliate_id_and_phrase_and_is_protected(routed_query.affiliate.id, 'some keyword', true)
      expect(sayt_suggestion).to be_nil
    end
  end

  describe 'label' do
    it 'returns the keyword' do
      expect(routed_query_keywords(:one).label).to eq('unclaimed money owed to me')
    end
  end

  describe '#dup' do
    subject(:original_instance) { routed_query_keywords(:one) }
    include_examples 'dupable', %w(routed_query_id)
  end
end
