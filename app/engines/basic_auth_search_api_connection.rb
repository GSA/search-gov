class BasicAuthSearchApiConnection < CachedSearchApiConnection
  extend Forwardable
  def_delegator :@connection, :basic_auth

  def get(api_endpoint, param_hash)
    response = @cache.read api_endpoint, param_hash
    return response if response

    response = @connection.get api_endpoint, param_hash
    cache_response api_endpoint, param_hash, response
    response
  end
end
