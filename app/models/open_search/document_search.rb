# frozen_string_literal: true

class OpenSearch::DocumentSearch
  NO_HITS = { 'hits' => { 'total' => 0, 'hits' => [] } }
  CACHE_NAMESPACE = 'searches'
  RACE_CONDITION_TTL = 10.seconds
  DEFAULT_CACHE_MINUTES = 15

  attr_reader :doc_query, :offset, :size, :indices, :from_cache

  def initialize(options, affiliate:)
    @options = options
    @affiliate = affiliate
    @doc_query = OpenSearch::DocumentQuery.new(options, affiliate:)
    @indices = options[:indices]
    @offset = options[:offset] || 0
    @size = options[:size]
    @skip_cache = options[:skip_cache]
    @from_cache = false
  end

  def search
    search_results = execute_client_search
    if search_results.total.zero? && search_results.suggestion.present?
      suggestion = search_results.suggestion
      doc_query.query = suggestion['text']
      search_results = execute_client_search
      search_results.override_suggestion(suggestion) if search_results.results.present?
    end
    search_results
  end

  private

  def execute_client_search
    OpenSearch::DocumentSearchResults.new(fetch_client_result, offset)
  end

  def fetch_client_result
    return client_search if skip_cache?

    @from_cache = true
    Rails.cache.fetch(cache_key, **cache_options) do
      @from_cache = false
      client_search
    end
  end

  def skip_cache?
    @skip_cache || cache_duration <= 0
  end

  def cache_duration
    ENV.fetch('OPENSEARCH_CACHE_DURATION', DEFAULT_CACHE_MINUTES.to_s).to_i.minutes
  end

  def cache_options
    {
      expires_in: cache_duration,
      namespace: CACHE_NAMESPACE,
      race_condition_ttl: RACE_CONDITION_TTL
    }
  end

  def cache_key
    Digest::SHA256.hexdigest(JSON.generate(cache_key_payload.as_json.sort.to_h))
  end

  def cache_key_payload
    {
      affiliate_id: @affiliate.id,
      gets_results_from_all_domains: @affiliate.gets_results_from_all_domains,
      locale: @affiliate.locale,
      indices: Array(indices),
      offset: offset,
      size: size,
      query: normalized_query,
      language: @options[:language],
      include: @options[:include],
      ignore_tags: @options[:ignore_tags],
      sort_by_date: @options[:sort_by_date],
      min_timestamp: @options[:min_timestamp],
      max_timestamp: @options[:max_timestamp],
      min_timestamp_created: @options[:min_timestamp_created],
      max_timestamp_created: @options[:max_timestamp_created],
      audience: @options[:audience],
      content_type: @options[:content_type],
      mime_type: @options[:mime_type],
      searchgov_custom1: @options[:searchgov_custom1],
      searchgov_custom2: @options[:searchgov_custom2],
      searchgov_custom3: @options[:searchgov_custom3],
      tags: @options[:tags]
    }
  end

  def normalized_query
    (doc_query.query || @options[:query]).to_s.downcase.squish
  end

  def client_search
    Rails.logger.debug { "Query: *****\n#{doc_query.body.to_json}\n*****" }

    result = OPENSEARCH_CLIENT.search({
      index: indices,
      body: doc_query.body,
      from: offset,
      size: size,
      rest_total_hits_as_int: true
    })

    payload = result.is_a?(Hash) ? result : result.to_hash
    raise TypeError, 'OpenSearch client returned a non-Hash result' unless payload.is_a?(Hash)

    payload
  end
end
