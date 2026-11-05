# frozen_string_literal: true

shared_context 'with the OpenSearch cache enabled' do
  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  around do |example|
    saved = ENV.fetch('REDIS_CACHE_ON', nil)
    ENV['REDIS_CACHE_ON'] = 'true'
    example.run
  ensure
    ENV['REDIS_CACHE_ON'] = saved
  end

  before do
    affiliate.update!(search_cache_enabled: true)
    affiliate.site_domains.create!(domain: 'nps.gov')
    allow(Rails).to receive(:cache).and_return(cache)
    allow(OPENSEARCH_CLIENT).to receive(:search).and_return(OpenSearch::DocumentSearch::NO_HITS)
  end

  def search_cache_keys
    cache.instance_variable_get(:@data).keys.grep(/\Asearches:/)
  end

  def cache_key_for(params)
    cache.clear
    perform(params)
    keys = search_cache_keys
    expect(keys.size).to eq(1), "expected one searches cache key for #{params.inspect}, got #{keys.inspect}"
    keys.first
  end
end
