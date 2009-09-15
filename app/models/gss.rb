class Gss < AbstractEngine
  require 'net/http'
  require 'cgi'
  DEFAULT_PER_PAGE = 20
  API_URL = 'http://www.google.com/search'

  def run
    logger = RAILS_DEFAULT_LOGGER
    startindex = @page * DEFAULT_PER_PAGE
    q = @query
    if @affiliate && !@affiliate.domains.blank?
      q = "#{q} #{@affiliate.domain_list}"
    end
    opts = {:start => startindex,
            :num => DEFAULT_PER_PAGE,
            :q =>  q,
            :ie => "utf8",
            :oe => "utf8",
            :client => "google-csbe",
            :output => "xml_no_dtd",
            :cx => "009969014417352305501:4bohptsvhei"
    }
    #logger.debug "debugger opts: #{opts.inspect}"
    request_url = prepare_url(opts)
    #logger.debug "Request URL: #{request_url}"
    begin
      res = Net::HTTP.get_response(URI::parse(request_url))
      #logger.debug "HTTP status: #{res.code} #{res.message}"
      unless res.kind_of? Net::HTTPSuccess
        raise RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      #logger.debug "Response body: #{res.body}"
      doc = Hpricot.parse(res.body)
      results_array = (doc/:r).collect do |r|
        unescaped_url = r.search("/ue").first.children.first
        cache_url = API_URL+"?q="+ ["cache", r.search("/has/c").first["CID"], unescaped_url].join(':') rescue ""
        title = r.search("/t").first.children.first
        logger.debug "title: #{title}"
        content = r.search("/s").first.children.first
        {'title' => title, 'unescapedUrl'=> unescaped_url, 'content'=> content, 'cacheUrl'=> cache_url}
      end

      self.total = (doc/:m).first.children.first.raw_string.to_i rescue 0
      pagination_total = [ DEFAULT_PER_PAGE * 20, self.total ].min
      self.results = WillPaginate::Collection.create(@page+1, DEFAULT_PER_PAGE, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = startindex + 1
      self.endrecord = self.startrecord + self.results.size - 1
    rescue SocketError, Errno::ECONNREFUSED => e
      logger.warn "Error connecting to server: #{e}"
    rescue RequestError => e
      logger.warn "Search failed: #{e}"
      false
    end
    true
  end

  private

  def prepare_url(opts)
    qs = []
    opts.each {|k, v| qs << "#{k}=#{URI.encode(v.to_s)}" if v }
    "#{API_URL}?#{qs.sort.join('&')}"
  end
end

class RequestError < StandardError;
end
