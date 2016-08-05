class ApiGoogleSearch < ApiWebSearch
  self.default_module_tag = 'GWEB'.freeze

  def query_formatting_klass
    GoogleFormattedQuery
  end

  def engine_klass
    GoogleWebSearch
  end

  protected

  def handle_response(response)
    return unless response
    @total = response.total
    @results = response.results
    @next_offset = (response.results.length < 10) ? nil : response.end_record
  end
end