require 'spec_helper'

describe Searches::PathsHelper do
  fixtures :affiliates, :i14y_drawers, :i14y_memberships
  let(:affiliate) { affiliates(:power_affiliate) }

  describe '#path_for_filterable_search', type: :request do
    context 'I14y search' do
      let(:i14y_search) { I14ySearch.new(affiliate: affiliate,
                                        sort_by: 'date',
                                        tbs: 'm',
                                        per_page: 20,
                                        query: 'test query') }

      it 'returns the correct search path' do
        get '/search'
        expected_params = { affiliate: affiliate, query: 'test query', sort_by: 'date', tbs: 'm' }
        expect(helper.path_for_filterable_search(i14y_search, {affiliate: affiliate}, {})).to eq(search_path expected_params)
      end

      it 'is based on the original path' do
        get "/search/docs"
        expected_params = { affiliate: affiliate, query: 'test query', sort_by: 'date', tbs: 'm' }
        expect(helper.path_for_filterable_search(i14y_search, {affiliate: affiliate}, {})).to eq(docs_search_path expected_params)
      end
    end
  end
end
