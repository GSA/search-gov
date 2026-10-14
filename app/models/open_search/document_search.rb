# frozen_string_literal: true

class OpenSearch::DocumentSearch
  NO_HITS = { 'hits' => { 'total' => 0, 'hits' => [] } }
  CACHE_NAMESPACE = 'searches'
  CACHE_KEY_VERSION = 'v1'
  RACE_CONDITION_TTL = 10.seconds
  DEFAULT_CACHE_MINUTES = 15
  QUERY_OPERATORS = %w[AND OR NOT].freeze

  attr_reader :doc_query, :offset, :size, :indices, :cache_status

  def self.normalize_query(query)
    query.to_s.split.map { |term| QUERY_OPERATORS.include?(term) ? term : term.downcase }.join(' ')
  end

  def initialize(options, affiliate:)
    @options = options
    @affiliate = affiliate
    @doc_query = OpenSearch::DocumentQuery.new(options, affiliate:)
    @indices = options[:indices]
    @offset = options[:offset] || 0
    @size = options[:size]
    @cache_status = nil
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
    body = doc_query.body.to_hash

    if cache_disabled?
      @cache_status = 'disabled'
      return client_search(body)
    end

    @cache_status = 'hit'
    Rails.cache.fetch(cache_key(body), **cache_options) do
      @cache_status = 'miss'
      client_search(body)
    end
  end

  def cache_disabled?
    !ENV['REDIS_CACHE_ON'].to_s.strip.casecmp?('true') ||
      !@affiliate.search_cache_enabled? ||
      cache_duration <= 0
  end

  def cache_duration
    minutes = Integer(ENV.fetch('REDIS_CACHE_DURATION', DEFAULT_CACHE_MINUTES).to_s.strip, 10, exception: false)
    (minutes || DEFAULT_CACHE_MINUTES).minutes
  end

  def cache_options
    {
      expires_in: cache_duration,
      namespace: CACHE_NAMESPACE,
      race_condition_ttl: RACE_CONDITION_TTL
    }
  end

  def cache_key(body)
    payload = [Array(indices), offset, size, normalized_body(body)]
    "#{@affiliate.id}:#{CACHE_KEY_VERSION}:#{Digest::SHA256.hexdigest(JSON.generate(payload))}"
  end

  # Only the user query is case-folded; filters such as site paths keep their case.
  # Timestamps are floored to the minute so relative ranges like tbs=h stay cacheable.
  def normalized_body(body)
    raw_query = doc_query.query.to_s
    normalized_query = self.class.normalize_query(raw_query)

    body.deep_transform_values do |value|
      case value
      when raw_query then normalized_query
      when Time, DateTime, ActiveSupport::TimeWithZone then value.utc.change(sec: 0).iso8601
      else value
      end
    end
  end

  def client_search(body)
    Rails.logger.debug { "Query: *****\n#{body.to_json}\n*****" }

    result = OPENSEARCH_CLIENT.search({
      index: indices,
      body: body,
      from: offset,
      size: size,
      rest_total_hits_as_int: true
    })

    payload = result.is_a?(Hash) ? result : result.to_hash
    raise TypeError, 'OpenSearch client returned a non-Hash result' unless payload.is_a?(Hash)

    payload
  end
end
