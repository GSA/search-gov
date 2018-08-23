class ApiBingSearch < ApiWebSearch
  self.default_module_tag = 'BWEB'.freeze

  def query_formatting_klass
    BingFormattedQuery
  end

  def engine_klass
    latest_bing_web_search_class
  end

  protected

  def latest_bing_web_search_class
    BingV6WebSearch
  end

  def handle_response(response)
    return unless response
    @total = response.total
    @results = response.results
    @next_offset = (response.results.length < 10) ? nil : response.end_record
  end
end
