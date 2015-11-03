class AzureEngine < SearchEngine
  API_HOST = 'https://api.datamarket.azure.com'.freeze
  CACHE_LIFETIME = 60 * 60 * 24 # seconds

  class_attribute :azure_api_connection, instance_writer: false
  class_attribute :azure_parameters_class, instance_writer: false
  class_attribute :api_name, instance_writer: false
  attr_reader :azure_params

  self.azure_parameters_class = AzureParameters

  def initialize(options)
    super
    self.api_connection = connection_instance
    @password = options[:password]
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

  def connection_instance
    raise 'api_name not implemented' unless api_name
    self.class.azure_api_connection ||= BasicAuthSearchApiConnection.new(api_name, API_HOST, CACHE_LIFETIME)
  end
end
