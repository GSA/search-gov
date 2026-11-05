# frozen_string_literal: true

require 'spec_helper'

# Every permitted search param must either change the OpenSearch cache key or be
# listed as not affecting the OpenSearch request. A new param fails here until classified.
describe SearchesController, type: :controller do
  include_context 'with the OpenSearch cache enabled'

  let(:base_params) { { affiliate: affiliate.name, query: 'electro coagulation' } }

  let(:key_changing_values) do
    {
      audience: 'veterans',
      content_type: 'article',
      'query-not': 'grants',
      'query-or': 'loans',
      'query-quote': 'small business',
      include_facets: 'true',
      mime_type: 'application/pdf',
      page: '2',
      query: 'other topic',
      searchgov_custom1: 'alpha',
      searchgov_custom2: 'beta',
      searchgov_custom3: 'gamma',
      since_date: '01/01/2026',
      siteexclude: 'example.gov',
      sitelimit: 'nps.gov/subject',
      sort_by: 'date',
      tbs: 'w',
      until_date: '02/01/2026'
    }
  end

  # Params that are permitted on the web SERP but never reach the OpenSearch request.
  # tags is permitted but not forwarded by DocumentSearchable#facet_filter_hash.
  let(:non_request_params) do
    %i[
      affiliate autodiscovery_url changed channel commit contributor cr created dc
      filetype filter hl publisher redesign subject tags utf8
    ]
  end

  def perform(params)
    get :index, params: params
  end

  it 'classifies every permitted param' do
    unclassified = ApplicationController::PERMITTED_PARAM_KEYS.map(&:to_sym) -
                   key_changing_values.keys - non_request_params
    expect(unclassified).to be_empty
  end

  it 'changes the key for every param that reaches OpenSearch' do
    base_key = cache_key_for(base_params)

    unchanged = key_changing_values.select do |param, value|
      cache_key_for(base_params.merge(param => value)) == base_key
    end

    expect(unchanged.keys).to be_empty
  end

  it 'keeps the key for params that do not reach OpenSearch' do
    base_key = cache_key_for(base_params)
    samples = { autodiscovery_url: 'https://usa.gov', channel: '1', commit: 'Search', cr: 'US',
                disable_search_cache: 'true', hl: 'false', redesign: 'true', utf8: '✓' }

    changed = samples.reject { |param, value| cache_key_for(base_params.merge(param => value)) == base_key }

    expect(changed.keys).to be_empty
  end

  it 'shares a key across query casing' do
    expect(cache_key_for(base_params.merge(query: 'Electro COAGULATION'))).to eq(cache_key_for(base_params))
  end

  it 'treats a missing page and page 1 the same' do
    expect(cache_key_for(base_params.merge(page: '1'))).to eq(cache_key_for(base_params))
  end

  it 'records the cache status in the impression diagnostics' do
    get :index, params: base_params
    get :index, params: base_params

    expect(assigns[:search].diagnostics['SRCH']).to eq(cached: true, cache: 'hit')
  end

  it 'ignores the retired disable_search_cache param and serves from the cache' do
    get :index, params: base_params
    get :index, params: base_params.merge(disable_search_cache: 'true')

    expect(response).to have_http_status(:ok)
    expect(assigns[:search].diagnostics['SRCH']).to eq(cached: true, cache: 'hit')
    expect(search_cache_keys.size).to eq(1)
  end

  it 'reports disabled and skips Redis when the affiliate turns the cache off' do
    affiliate.update!(search_cache_enabled: false)
    get :index, params: base_params

    expect(assigns[:search].diagnostics['SRCH']).to eq(cached: false, cache: 'disabled')
    expect(search_cache_keys).to be_empty
  end
end
