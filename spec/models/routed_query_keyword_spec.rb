# frozen_string_literal: true

describe RoutedQueryKeyword do
  fixtures :affiliates, :routed_queries, :routed_query_keywords
  let(:routed_query) { routed_queries(:unclaimed_money) }

  describe 'Creating new instance' do
    it { is_expected.to belong_to(:routed_query).inverse_of(:routed_query_keywords) }
    it { is_expected.to validate_presence_of :routed_query }
    it { is_expected.to validate_presence_of :keyword }
    it { is_expected.to validate_uniqueness_of(:keyword).scoped_to(:routed_query_id).case_insensitive }

    it 'creates a new instance given valid attributes' do
      routed_query.routed_query_keywords.create!(keyword: 'route me')
    end

    it 'downcases, squish and strip whitespace from keyword before inserting in DB' do
      keyword = ' leading          and trailing whitespaces AND CAPITALS'
      rqk = routed_query.routed_query_keywords.create!(keyword: keyword)
      expect(rqk.keyword).to eq('leading and trailing whitespaces and capitals')
    end

    it 'does not allow the same keyword to be reused within a single affiliate' do
      routed_queries(:unclaimed_money).routed_query_keywords.create!(keyword: 'route me')
      rqk = routed_queries(:moar_unclaimed_money).routed_query_keywords.build(
        keyword: 'route me'
      )
      expected_error =
        'The keyword \'route me\' is already in use for a different routed query'

      expect(rqk).not_to be_valid
      expect(rqk.errors[:keyword]).to eq([expected_error])
    end

    it 'creates a matching SaytSuggestion' do
      routed_query.routed_query_keywords.create!(keyword: 'route me')
      sayt_suggestion = SaytSuggestion.find_by(affiliate_id: routed_query.affiliate.id,
                                               phrase: 'route me',
                                               is_protected: true)
      expect(sayt_suggestion).to be_present
    end

    context 'when a keyword contains html' do
      let(:keyword) do
        routed_query.routed_query_keywords.create!(
          keyword: 'keyword <div>with html'
        )
      end

      it 'strips the html from the keyword' do
        expect(keyword.keyword).to eq('keyword with html')
      end
    end
  end

  describe 'Updating a keyword' do
    before do
      keyword = routed_query.routed_query_keywords.create!(keyword: 'initial keyword')
      keyword.update(keyword: 'updated keyword')
    end

    it 'updates the matching SaytSuggestion' do
      sayt_suggestion = SaytSuggestion.find_by(affiliate_id: routed_query.affiliate.id,
                                               phrase: 'updated keyword',
                                               is_protected: true)
      expect(sayt_suggestion).to be_present
    end
  end

  describe 'deleting a keyword' do
    before do
      routed_query.routed_query_keywords.create!(keyword: 'some keyword')
    end

    it 'deletes the matching SaytSuggestion' do
      described_class.last.destroy
      sayt_suggestion = SaytSuggestion.find_by(affiliate_id: routed_query.affiliate.id,
                                               phrase: 'some keyword',
                                               is_protected: true)

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

    include_examples 'dupable', %w[routed_query_id]
  end
end
