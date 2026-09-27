# frozen_string_literal: true

require 'spec_helper'

# Every permitted search param must either change the OpenSearch cache key or be
# listed as not affecting the OpenSearch request. A new param fails here until classified.
describe Api::V2::SearchesController, type: :controller do
  include_context 'with the OpenSearch cache enabled'

  let(:base_params) do
    { affiliate: affiliate.name, access_key: affiliate.api_access_key, query: 'electro coagulation', format: 'json' }
  end

  let(:key_changing_values) do
    {
      audience: 'veterans',
      content_type: 'article',
      created_since: '2026-01-01',
      created_until: '2026-02-01',
      include_facets: 'true',
      limit: '5',
      mime_type: 'application/pdf',
      offset: '5',
      query: 'other topic',
      query_not: 'grants',
      query_or: 'loans',
      query_quote: 'small business',
      searchgov_custom1: 'alpha',
      searchgov_custom2: 'beta',
      searchgov_custom3: 'gamma',
      sitelimit: 'nps.gov/subject',
      sort_by: 'date',
      updated_since: '2026-01-01',
      updated_until: '2026-02-01'
    }
  end

  # tags is permitted but not forwarded by DocumentSearchable#facet_filter_hash.
  let(:non_request_params) do
    %i[access_key affiliate api_key dc disable_search_cache enable_highlighting filetype filter format routed tags]
  end

  def perform(params)
    get :i14y, params: params
  end

  it 'classifies every permitted param' do
    source = File.read(described_class.instance_method(:search_params).source_location.first)
    permitted = source[/params\.permit\((.*?)\)\.to_h/m, 1].scan(/:(\w+)/).flatten.map(&:to_sym)

    expect(permitted).to include(:query, :disable_search_cache)
    expect(permitted - key_changing_values.keys - non_request_params).to be_empty
  end

  it 'changes the key for every param that reaches OpenSearch' do
    base_key = cache_key_for(base_params)

    unchanged = key_changing_values.select do |param, value|
      cache_key_for(base_params.merge(param => value)) == base_key
    end

    expect(unchanged.keys).to be_empty
  end

  it 'keeps the key when enable_highlighting or the bypass flag differ' do
    base_key = cache_key_for(base_params)

    expect(cache_key_for(base_params.merge(enable_highlighting: 'false'))).to eq(base_key)
    expect(cache_key_for(base_params.merge(disable_search_cache: 'false'))).to eq(base_key)
  end

  it 'bypasses without writing when disable_search_cache is 1' do
    get :i14y, params: base_params.merge(disable_search_cache: '1')

    expect(assigns[:search].diagnostics['SRCH']).to eq(cached: false, cache: 'bypass')
    expect(search_cache_keys).to be_empty
  end
end
