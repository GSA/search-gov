require 'spec_helper'

describe Searches::PathsHelper do

  fixtures :affiliates, :i14y_drawers, :i14y_memberships
  let(:affiliate) { affiliates(:power_affiliate) }

  describe '#path_for_filterable_search' do
    context 'I14y search' do
      let(:i14y_search) { I14ySearch.new(affiliate: affiliate,
                                        sort_by: 'date',
                                        tbs: 'm',
                                        per_page: 20,
                                        dc: 1,
                                        query: 'test query') }

      it 'returns the correct search path' do
        expected_params = { affiliate: affiliate, query: 'test query', sort_by: 'date', tbs: 'm', dc: 1 }
        expect(helper.path_for_filterable_search(i14y_search, {affiliate: affiliate, dc: 1}, {})).to eq(docs_search_path expected_params)
      end
    end

    context 'Blended search' do
      let(:blended_search) { BlendedSearch.new(affiliate: affiliate,
                                               sort_by:   'date',
                                               tbs:       'm',
                                               query:     'test query') }

      it 'returns the correct search path' do
        expected_params = { affiliate: affiliate, query: 'test query', sort_by: 'date', tbs: 'm' }
        expect(helper.path_for_filterable_search(blended_search, {affiliate: affiliate}, {})).to eq(search_path expected_params)
      end
    end


    context 'News search' do
      let(:news_search) { NewsSearch.new(affiliate: affiliate,
                                         sort_by:   'date',
                                         tbs:       'm',
                                         query:     'test query') }

      it 'returns the correct search path' do
        expected_params = { affiliate: affiliate, query: 'test query', sort_by: 'date', tbs: 'm' }
        expect(helper.path_for_filterable_search(news_search, {affiliate: affiliate}, {})).to eq(news_search_path expected_params)
      end
    end
  end
end
