class AzureParameters
  attr_reader :limit, :offset

  def initialize(options)
    @limit = options[:limit]
    @offset = options[:offset]

    @params = {
      :'$format' => 'JSON',
      :'$skip' => @offset,
      :'$top' => @limit,
      :Market => wrap_param_in_quotes("#{options[:language]}-US"),
      :Query => wrap_param_in_quotes(options[:query])
    }
    enable_highlighting if options[:enable_highlighting]
  end

  def to_hash
    @params
  end

  private

  def enable_highlighting
    @params[:Options] = wrap_param_in_quotes('EnableHighlighting')
  end

  def wrap_param_in_quotes(param_value)
    "'#{param_value}'"
  end
end
