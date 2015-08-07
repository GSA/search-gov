class AzureCompositeParameters < AzureParameters
  def initialize(options)
    super
    @params[:Sources] = wrap_param_in_quotes options[:sources]
    @params[:ImageFilters] = wrap_param_in_quotes options[:image_filters]
  end
end
