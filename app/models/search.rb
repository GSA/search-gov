class Search
  require 'google/gweb_search'
  attr_accessor :queryterm, :results, :page, :total

  def initialize(options = {})
    options ||= {}
    self.queryterm = options[:queryterm] || ''
    #self.page = [options[:page].to_i, 1].max
    #@per_page = 10
  end

  def run
    begin
      #Google::GwebSearch.options[:key] = "some key"
      Google::GwebSearch.options[:rsz] = "large"
      Google::GwebSearch.options[:hl] = "en"
      #set language/logger?
      response = Google::GwebSearch.search(self.queryterm)
      self.results = response.results
      json = JSON.parse(response.json)
      self.total = json["responseData"]["cursor"]["estimatedResultCount"].to_i
      RAILS_DEFAULT_LOGGER.debug "got #{self.results.size} results for #{self.queryterm}"
    rescue RuntimeError => e
      RAILS_DEFAULT_LOGGER.warn "Search failed: #{e}"
      return false
    end
    true
  end

  def id
    #workaround for deprecation warning since Search is not an active record class
  end
end