class Bing < AbstractEngine
  DEFAULT_PER_PAGE = 10

  def run
    options = {}
    options[:offset] = @page * DEFAULT_PER_PAGE if @page > 0
    if @affiliate && !@affiliate.domains.blank?
      options[:site] = @affiliate.domains.split("\n")
    else
      options[:site] = ["gov", "mil"]
    end
    bing = RBing.new("A4C32FAE6F3DB386FC32ED1C4F3024742ED30906")
    q = @query

    begin
      response = bing.web(q, options)
      self.total = response.web.total
      pagination_total = [DEFAULT_PER_PAGE * 20, self.total ].min
      results_array = self.total > 0 ? response.web.results.collect do |r|
        {'title' => r.title,
         'unescapedUrl'=> r.url,
         'content'=> (r.description rescue ""),
         'cacheUrl'=> (r.CacheUrl rescue ""),
         'deepLinks' => r["DeepLinks"]
        }
      end : []
      self.results = WillPaginate::Collection.create(@page+1, DEFAULT_PER_PAGE, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = @page * DEFAULT_PER_PAGE + 1
      self.endrecord = self.startrecord + self.results.size - 1
    rescue SocketError, Errno::ECONNREFUSED => e
      RAILS_DEFAULT_LOGGER.warn "Error connecting to server: #{e}"
      false
    end
    true
  end
end