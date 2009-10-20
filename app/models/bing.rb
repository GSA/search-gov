class Bing < AbstractEngine
  DEFAULT_PER_PAGE = 10
  JSON_SITE="http://api.search.live.net/json.aspx"
  APP_ID="A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  SOURCES = %w{Spell Web RelatedSearch}.join('+')

  def run
    offset = @page > 0 ? @page * DEFAULT_PER_PAGE : 0
    if @affiliate && !@affiliate.domains.blank?
      sites = @affiliate.domains.split("\n")
    else
      sites = ["gov", "mil"]
    end
    sites_str = sites.collect {|site| "site:#{site}"}.join(" OR ")
    sites_clause = "(#{sites_str})"
    q = "#{@query.strip} #{sites_clause}"

    begin
      uri = URI.parse("#{JSON_SITE}?web.offset=#{offset}&AppId=#{APP_ID}&sources=#{SOURCES}&query=#{URI.escape(q)}")
      resp = Net::HTTP.get_response(uri)
      json = JSON.parse(resp.body)
      response = ResponseData.new(json['SearchResponse'])

      self.total = response.web.total
      self.spelling_suggestion = response.spell.results.first.value rescue nil
      pagination_total = [DEFAULT_PER_PAGE * 20, self.total ].min
      results_array= []
      if self.total > 0
        results_array = response.web.results.collect do |r|
          {'title' => r.title,
           'unescapedUrl'=> r.url,
           'content'=> (r.description rescue ""),
           'cacheUrl'=> (r.CacheUrl rescue ""),
           'deepLinks' => r["DeepLinks"]
          }
        end
        self.related_search = response.related_search.results rescue []
      end
      self.results = WillPaginate::Collection.create(@page+1, DEFAULT_PER_PAGE, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = @page * DEFAULT_PER_PAGE + 1
      self.endrecord = self.startrecord + self.results.size - 1
    rescue SocketError, Errno::ECONNREFUSED => e
      RAILS_DEFAULT_LOGGER.warn "Error connecting to server: #{e}"
      false
    end
    true
  end

  class ResponseData < Hash
    private
    def initialize(data={})
      data.each_pair {|k, v| self[k.to_s] = deep_parse(v) }
    end

    def deep_parse(data)
      case data
        when Hash
          self.class.new(data)
        when Array
          data.map {|v| deep_parse(v) }
        else
          data
      end
    end

    def method_missing(*args)
      name = args[0].to_s
      return self[name] if has_key? name
      camelname = name.split('_').map {|w| "#{w[0, 1].upcase}#{w[1..-1]}" }.join("")
      if has_key? camelname
        self[camelname]
      else
        super *args
      end
    end
  end

end
