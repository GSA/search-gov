class ApiAzureSearch < ApiWebSearch
  self.default_module_tag = 'AWEB'.freeze

  def query_formatting_klass
    AzureFormattedQuery
  end

  def engine_klass
    AzureWebEngine
  end
end