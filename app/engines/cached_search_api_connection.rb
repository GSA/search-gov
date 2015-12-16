CachedSearchApiConnectionResponse = Struct.new(:response, :cache_namespace)

class CachedSearchApiConnection
  extend Forwardable
  def_delegator :@connection, :basic_auth # optional
  attr_reader :connection

  def initialize(namespace, site, cache_duration = 60 * 60 * 6)
    @connection = Faraday.new site do |conn|
      conn.request :json
      conn.response :rashify
      conn.response :json
      conn.headers[:user_agent] = 'USASearch'
      ExternalFaraday.configure_connection namespace, conn
    end
    @cache = ApiCache.new namespace, cache_duration
  end

  def get(api_endpoint, param_hash)
    if response = @cache.read(api_endpoint, param_hash)
      CachedSearchApiConnectionResponse.new(response, @cache.namespace)
    else
      response = get_from_api(api_endpoint, param_hash)
      CachedSearchApiConnectionResponse.new(response, 'none')
    end
  end

  protected

  def get_from_api(api_endpoint, param_hash)
    response = @connection.get api_endpoint, param_hash
    cache_response api_endpoint, param_hash, response
    response
  end

  def cache_response(api_endpoint, param_hash, response)
    if response.status == 200
      @cache.write api_endpoint, param_hash, response
    end
  end
end
