class Gweb < AbstractEngine
  require 'google/gweb_search'
  DEFAULT_PER_PAGE = 8

  def run
    startindex = @page * DEFAULT_PER_PAGE

    Google::GwebSearch.logger = RAILS_DEFAULT_LOGGER
    Google::GwebSearch.options[:rsz] = "large"
    Google::GwebSearch.options[:hl] = "en"
    Google::GwebSearch.options[:start] = startindex
    cx = '012983105564958037848:xhukbbvbwi0'
    q = @query
    if @affiliate && !@affiliate.domains.blank?
      cx = nil
      q = "#{q} #{@affiliate.domain_list}"
    end
    Google::GwebSearch.options[:cx] = cx

    begin
      response = Google::GwebSearch.search(q)
      json = JSON.parse(response.json)
      self.total = json["responseData"]["cursor"]["estimatedResultCount"].to_i
      # FIXME: GWebSearch fails when start > 56 so I'm hardcoding total to 64
      pagination_total = [ 64, self.total ].min
      self.results = WillPaginate::Collection.create(@page+1, DEFAULT_PER_PAGE, pagination_total) { |pager| pager.replace(response.results) }
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

module Google
  module GwebSearch
    class << self
      private
      def prepare_url(opts)
        qs = []
        opts.each {|k, v| qs << "#{k}=#{URI.encode(v.to_s)}" if v }
        "#{API_URL}?#{qs.sort.join('&')}"
      end
    end
  end
end