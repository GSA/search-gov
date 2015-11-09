class AzureEngine < SearchEngine
  API_HOST = 'https://api.datamarket.azure.com'.freeze
  CACHE_LIFETIME = 60 * 60 * 24 # seconds
  DEFAULT_AZURE_HOSTED_PASSWORD = YAML.load_file("#{Rails.root}/config/hosted_azure.yml")[Rails.env]['account_key'].freeze
  NAMESPACE = 'azure_api'.freeze

  class_attribute :azure_parameters_class, instance_writer: false
  attr_reader :azure_params

  self.azure_parameters_class = AzureParameters

  def initialize(options)
    super
    @password = get_password(options)
    self.api_connection = connection_instance(@password)
    @azure_params = azure_parameters_class.new options
  end

  def execute_query
    api_connection.basic_auth nil, @password
    super
  end

  def params
    azure_params.to_hash
  end

  protected

  def connection_instance(password)
    password == DEFAULT_AZURE_HOSTED_PASSWORD ? rate_limited_api_connection : unlimited_api_connection
  end

  def unlimited_api_connection
    @@azure_unlimited_api_connection ||= CachedSearchApiConnection.new(NAMESPACE, API_HOST, CACHE_LIFETIME)
  end

  def rate_limited_api_connection
    @@azure_rate_limited_api_connection ||= RateLimitedSearchApiConnection.new(NAMESPACE, API_HOST, CACHE_LIFETIME, true)
  end

  def get_password(options)
    if options.has_key? :password
      options[:password]
    else
      DEFAULT_AZURE_HOSTED_PASSWORD
    end
  end
end
