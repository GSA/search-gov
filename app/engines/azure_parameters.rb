class AzureParameters
  attr_reader :limit, :offset, :language

  def initialize(options)
    @limit = options[:limit]
    @offset = options[:offset]
    @language = options[:language]

    @params = {
      :'$format' => 'JSON',
      :'$skip' => @offset,
      :'$top' => @limit,
      :Market => wrap_param_in_quotes(market),
      :Query => wrap_param_in_quotes(options[:query])
    }
    enable_highlighting if options[:enable_highlighting]
  end

  def to_hash
    @params
  end

  private

  def market
    lang = Language.find_by_code(language)
    if lang && lang.is_azure_supported && lang.inferred_country_code
      "#{language}-#{lang.inferred_country_code}"
    else
      'en-US'
    end
  end

  def enable_highlighting
    @params[:Options] = wrap_param_in_quotes('EnableHighlighting')
  end

  def wrap_param_in_quotes(param_value)
    "'#{param_value}'"
  end
end
