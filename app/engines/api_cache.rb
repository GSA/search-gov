class ApiCache
  attr_reader :namespace

  def initialize(namespace, cache_duration = DEFAULT_CACHE_DURATION)
    @namespace = namespace
    @cache_duration = cache_duration
    @cache_store = ActiveSupport::Cache::FileStore.new self.class.file_store_root,
                                                       namespace: namespace,
                                                       expires_in: cache_duration
  end

  def read(api_endpoint, http_params)
    response = @cache_store.read generate_cache_key(api_endpoint, http_params)
    FaradayResponseBodyRashify.process_response(response) if response
    response
  end

  def write(api_endpoint, http_params, response)
    @cache_store.write generate_cache_key(api_endpoint, http_params), response unless @cache_duration.zero?
  end

  def self.file_store_root
    "#{Rails.root}/tmp/api_cache"
  end

  private

  def generate_cache_key(api_endpoint, http_params)
    uri_args = { path: api_endpoint }
    uri_args[:query] = http_params.to_param if http_params.present?
    uri = URI::HTTP.build uri_args
    uri.request_uri
  end
end
