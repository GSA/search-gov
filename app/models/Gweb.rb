class Gweb < AbstractEngine
  require 'google/gweb_search'
  DEFAULT_PER_PAGE = 8

  def run
    startindex = @page * DEFAULT_PER_PAGE

    Google::GwebSearch.logger = RAILS_DEFAULT_LOGGER
    Google::GwebSearch.options[:rsz] = "large"
    Google::GwebSearch.options[:hl] = "en"
    Google::GwebSearch.options[:start] = startindex
    Google::GwebSearch.options[:cx] ||= '012983105564958037848:xhukbbvbwi0'

    begin
      response = Google::GwebSearch.search(@query)
      # FIXME: GWebSearch fails when start > 56 so I'm hardcoding total to 64
      # Presumably this will go away when we use GOOG's search API and/or Bing
      self.results = WillPaginate::Collection.create(@page+1, DEFAULT_PER_PAGE, 64) { |pager| pager.replace(response.results) }
      json = JSON.parse(response.json)
      self.total = json["responseData"]["cursor"]["estimatedResultCount"].to_i
      self.startrecord = startindex + 1
      self.endrecord = self.startrecord + self.results.size - 1
      # FIXME: rescue all errors, like network errors
    rescue Google::GwebSearch::RequestError => e
      RAILS_DEFAULT_LOGGER.warn "Search failed: #{e}"
      false
    end
    true
  end
end