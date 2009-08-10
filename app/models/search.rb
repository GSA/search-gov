class Search
  require 'google/gweb_search'
  attr_accessor :queryterm, :results, :page, :total, :startrecord, :endrecord

  def initialize(options = {})
    options ||= {}
    self.queryterm = options[:queryterm] || ''
    self.page = [options[:page].to_i, 0].max
    @per_page = 8
  end

  def run
    begin
      startindex = self.page * @per_page
      Google::GwebSearch.logger = RAILS_DEFAULT_LOGGER
      Google::GwebSearch.options[:rsz] = "large"
      Google::GwebSearch.options[:hl] = "en"
      Google::GwebSearch.options[:start] = startindex
      Google::GwebSearch.options[:cx] ||= '012983105564958037848:xhukbbvbwi0'

      response = Google::GwebSearch.search(self.queryterm)
      # FIXME: GWebSearch fails when start > 56 so I'm hardcoding total to 64
      # Presumably this will go away when we use GOOG's search API and/or Bing
      self.results = WillPaginate::Collection.create(self.page+1, @per_page, 64) { |pager| pager.replace(response.results) }
      json = JSON.parse(response.json)
      self.total = json["responseData"]["cursor"]["estimatedResultCount"].to_i
      self.startrecord = startindex + 1
      self.endrecord = self.startrecord + self.results.size - 1
    rescue RuntimeError => e
      RAILS_DEFAULT_LOGGER.warn "Search failed: #{e}"
      return false
    end
    true
  end

  def id
    #workaround for deprecation warning since Search is not an ActiveRecord class
  end
end
