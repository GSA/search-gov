class AzureEngine < SearchEngine
  API_HOST = 'https://api.datamarket.azure.com'.freeze

  class_attribute :azure_parameters_class,
                  instance_writer: false
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
end
