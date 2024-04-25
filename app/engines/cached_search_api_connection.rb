# frozen_string_literal: true

class CachedSearchApiConnection
  extend Forwardable
  def_delegator :@connection, :basic_auth # optional
  attr_reader :connection

  def initialize(namespace, host, cache_duration = DEFAULT_CACHE_DURATION)
    @cache_duration = cache_duration
    @host           = host
    @connection     = Faraday.new(host) do |conn|
      conn.request(:json)
      conn.use(FaradayMiddleware::ExceptionNotifier, [namespace])
      conn.response(:raise_error)
      conn.response(:rashify)
      conn.response(:json)
      conn.headers[:user_agent] = 'USASearch'

      ExternalFaraday.configure_connection(namespace, conn)
    end
  end

  def get(api_endpoint, param_hash)
    Rails.cache.fetch(cache_key(api_endpoint, param_hash), expires_in: @cache_duration) do
      @connection.get(api_endpoint, param_hash)
    end
  end

  protected

  def cache_key(api_endpoint, http_params)
    uri_args = { path: api_endpoint, host: @host }
    uri_args[:query] = http_params.to_param if http_params.present?
    URI::HTTP.build(uri_args).request_uri
  end
end
