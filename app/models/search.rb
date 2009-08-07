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
      Google::GwebSearch.logger = RAILS_DEFAULT_LOGGER
      Google::GwebSearch.options[:rsz] = "large"
      Google::GwebSearch.options[:hl] = "en"
      Google::GwebSearch.options[:start] = self.page
      response = Google::GwebSearch.search(self.queryterm)
      self.results = response.results
      json = JSON.parse(response.json)
      self.total = json["responseData"]["cursor"]["estimatedResultCount"].to_i
      self.startrecord = @per_page * self.page + 1
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