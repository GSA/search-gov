# frozen_string_literal: true

class CachedSearchApiConnection
  extend Forwardable

  attr_reader :namespace, :from_cache

  def_delegator :connection, :basic_auth # optional

  def initialize(namespace, host, cache_duration = DEFAULT_CACHE_DURATION)
    @namespace      = namespace
    @host           = host
    @cache_duration = cache_duration
  end

  def get(api_endpoint, param_hash = {})
    @from_cache = true
    Rails.cache.fetch(cache_key(api_endpoint, param_hash), expires_in: @cache_duration, namespace:) do
      @from_cache = false
      connection.get(api_endpoint, param_hash)
    end
  end

  def connection
    @connection ||= Faraday.new(@host) do |conn|
      conn.response(:logger)
      conn.request(:json)
      conn.use(FaradayMiddleware::ExceptionNotifier, [namespace])
      conn.response(:raise_error)
      conn.response(:rashify)
      conn.response(:json)
      conn.headers[:user_agent] = 'USASearch'

      ExternalFaraday.configure_connection(namespace, conn)
    end
  end

  def cache_key(api_endpoint, http_params)
    uri = URI::HTTP.build(path: api_endpoint, query: http_params.to_param)

    "#{@host}#{uri.request_uri}".gsub(/[^a-zA-Z0-9]+/, '/')
  end
end
