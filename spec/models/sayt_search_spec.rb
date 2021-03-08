require 'spec_helper'

describe SaytSearch do
  fixtures :affiliates
  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:es_affiliate) { affiliates(:gobiernousa_affiliate) }

  let(:sayt_suggestions) do
    sayt_suggestion1 = mock_model(SaytSuggestion, phrase: 'foo1')
    sayt_suggestion2 = mock_model(SaytSuggestion, phrase: 'foo2')
    [sayt_suggestion1, sayt_suggestion2]
  end

  before do
    common = {status: 'active', publish_start_on: Date.yesterday, description: 'blah'}
    affiliate.boosted_contents.create!(common.merge(url: 'http://www.agency.gov/boosted_content1.html', title: 'Foo Boosted Content 1'))
    affiliate.boosted_contents.create!(common.merge(url: 'http://www.agency.gov/boosted_content2.html', title: 'Foo Boosted Content 2'))
    es_affiliate.boosted_contents.create!(common.merge(url: 'http://www.agency.gov/boosted_content1.html', title: 'Foo Boosted Content 1'))
    es_affiliate.boosted_contents.create!(common.merge(url: 'http://www.agency.gov/boosted_content2.html', title: 'Foo Boosted Content 2'))
  end

  context 'when affiliate_id and query are present' do
    let(:query) { 'foo' }
    let(:search_params) { { affiliate_id: affiliate.id, locale: affiliate.locale, query: query, number_of_results: 10, extras: true } }
    let(:search) { SaytSearch.new(search_params) }

    it 'should correct query misspelling' do
      search_params[:query] = 'chold'

      expect(Misspelling).to receive(:correct).with('chold').and_return('child')
      expect(SaytSuggestion).to receive(:fetch_by_affiliate_id).with(affiliate.id, 'child', 10).and_return([])

      expect(search.results).to eq([])
    end

    it 'should return an array of hash' do
      expect(SaytSuggestion).to receive(:fetch_by_affiliate_id).with(affiliate.id, 'foo', 8).and_return(sayt_suggestions)

      expect(search.results).to eq([{ section: 'default', label: 'foo1' },
                                { section: 'default', label: 'foo2' },
                                { section: 'Recommended Pages', label: 'Foo Boosted Content 1', data: 'http://www.agency.gov/boosted_content1.html' },
                                { section: 'Recommended Pages', label: 'Foo Boosted Content 2', data: 'http://www.agency.gov/boosted_content2.html' }])
    end

    context 'when the affiliate locale is set to es' do
      let(:search_params) { { affiliate_id: es_affiliate.id, locale: es_affiliate.locale, query: query, number_of_results: 10, extras: true } }

      it 'should return an array of Hash with Spanish translations' do
        expect(SaytSuggestion).to receive(:fetch_by_affiliate_id).with(es_affiliate.id, 'foo', 8).and_return(sayt_suggestions)

        expect(search.results).to eq([{ section: 'default', label: 'foo1' },
                                  { section: 'default', label: 'foo2' },
                                  { section: 'Páginas recomendadas', label: 'Foo Boosted Content 1', data: 'http://www.agency.gov/boosted_content1.html' },
                                  { section: 'Páginas recomendadas', label: 'Foo Boosted Content 2', data: 'http://www.agency.gov/boosted_content2.html' }])
      end
    end
  end

  context 'when affiliate_id is not present' do
    let(:search_params) { { query: 'foo', number_of_results: 10, extras: true } }
    let(:search) { SaytSearch.new(search_params) }

    it 'should return an empty array' do
      expect(SaytSuggestion).not_to receive(:fetch_by_affiliate_id)

      expect(search.results).to eq([])
    end
  end

  context 'when query is not present' do
    let(:search_params) { { affiliate_id: affiliate.id, number_of_results: 10, extras: true } }
    let(:search) { SaytSearch.new(search_params) }

    it 'should return an empty array' do
      expect(SaytSuggestion).not_to receive(:fetch_by_affiliate_id)

      expect(search.results).to eq([])
    end
  end

  context 'when extras is false' do
    let(:search_params) { { affiliate_id: affiliate.id, query: 'foo', number_of_results: 10, extras: false } }
    let(:search) { SaytSearch.new(search_params) }

    it 'should return an empty array' do
      expect(SaytSuggestion).to receive(:fetch_by_affiliate_id).and_return(sayt_suggestions)

      expect(search.results).to eq(%w(foo1 foo2))
    end
  end
end
