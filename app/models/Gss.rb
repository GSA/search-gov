class Gss < AbstractEngine
  require 'net/http'
  require 'cgi'
  DEFAULT_PER_PAGE = 20
  API_URL = 'http://www.google.com/search'

  def run
    logger = RAILS_DEFAULT_LOGGER
    startindex = @page * DEFAULT_PER_PAGE
    opts = {:start => startindex,
            :num => DEFAULT_PER_PAGE,
            :q => @query,
            :client => "google-csbe",
            :output => "xml_no_dtd",
            :cx => "009969014417352305501:4bohptsvhei"
    }

    request_url = prepare_url(opts)
    logger.debug "Request URL: #{request_url}"
    begin
      res = Net::HTTP.get_response(URI::parse(request_url))
      logger.debug "HTTP status: #{res.code} #{res.message}"
      unless res.kind_of? Net::HTTPSuccess
        raise RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      logger.debug "Response body: #{res.body}"
      doc = Hpricot.parse(res.body)
      results_array = (doc/:r).collect do |r|
        unescapedUrl = r.search("/ue").first.children.first
        cacheUrl = API_URL+"?q="+ ["cache", r.search("/has/c").first["CID"], unescapedUrl].join(':') rescue ""
        title = r.search("/t").first.children.first
        content = r.search("/s").first.children.first
        {'title' => title, 'unescapedUrl'=> unescapedUrl, 'content'=> content, 'cacheUrl'=> cacheUrl}
      end

      self.total = (doc/:m).first.children.first.raw_string.to_i
      pagination_total = [ DEFAULT_PER_PAGE * 20 , self.total ].min
      self.results = WillPaginate::Collection.create(@page+1, DEFAULT_PER_PAGE, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = startindex + 1
      self.endrecord = self.startrecord + self.results.size - 1
    rescue RequestError => e
      RAILS_DEFAULT_LOGGER.warn "Search failed: #{e}"
      false
    end
    true
  end

  private

  def prepare_url(opts)
    qs = []
    opts.each {|k, v|
      next unless v
      v = v.join(',') if v.is_a? Array
      qs << "#{k}=#{URI.encode(v.to_s)}"
    }
    "#{API_URL}?#{qs.join('&')}"
  end
end

class RequestError < StandardError;
end
