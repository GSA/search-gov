class AzureEngine < SearchEngine
  API_HOST = 'https://api.datamarket.azure.com'.freeze
  NAMESPACE = 'azure_web_api'.freeze
  CACHE_LIFETIME = AZURE_CACHE_DURATION
  DEFAULT_AZURE_HOSTED_PASSWORD = YAML.load_file("#{Rails.root}/config/hosted_azure.yml")[Rails.env]['account_key'].freeze

  class_attribute :api_namespace
  class_attribute :azure_parameters_class, instance_writer: false
  attr_reader :azure_params

  self.api_namespace = NAMESPACE
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

  class << self
    def unlimited_api_connection
      @azure_unlimited_api_connection ||= { }
      @azure_unlimited_api_connection[self] ||= CachedSearchApiConnection.new(self.api_namespace, API_HOST, CACHE_LIFETIME)
    end

    def rate_limited_api_connection
      @azure_rate_limited_api_connection ||= { }
      @azure_rate_limited_api_connection[self] ||= RateLimitedSearchApiConnection.new(self.api_namespace, API_HOST, CACHE_LIFETIME, true)
    end
  end

  def connection_instance(password)
    password == DEFAULT_AZURE_HOSTED_PASSWORD ? self.class.rate_limited_api_connection : self.class.unlimited_api_connection
  end

  def get_password(options)
    if options.has_key? :password
      options[:password]
    else
      DEFAULT_AZURE_HOSTED_PASSWORD
    end
  end
end
