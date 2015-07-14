class ApiGssWebEngine < GoogleWebSearch
  attr_reader :language
  self.search_engine_response_class = CommercialSearchEngineResponse

  def initialize(options = {})
    super
    @language = options[:language]
    @next_offset_within_limit = options[:next_offset_within_limit]
  end

  protected

  def parse_search_engine_response(response)
    super do |google_response, search_response|
      search_response.next_offset = process_next_offset(google_response)
    end
  end

  def process_next_offset(google_response)
    if @next_offset_within_limit &&
      google_response.queries &&
      google_response.queries.next_page
      @offset + @per_page
    end
  end

  def mashify(title, unescaped_url, snippet)
    Hashie::Mash.new(description: snippet,
                     title: title,
                     url: unescaped_url)
  end
end
