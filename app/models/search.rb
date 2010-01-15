class Search
  attr_accessor :query, :page, :error_message, :affiliate, :total, :results, :startrecord, :endrecord, :related_search, :spelling_suggestion, :images, :boosted_sites
  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  JSON_SITE="http://api.search.live.net/json.aspx"
  APP_ID="A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  SOURCES = %w{Spell Web RelatedSearch Image}.join('+')

  def initialize(options = {})
    options ||= {}
    self.query = options[:query] || ''
    self.affiliate = options[:affiliate]
    self.page = [options[:page].to_i, 0].max
    self.results, self.related_search, self.images, self.boosted_sites = [], [], [], nil
  end

  def run
    self.error_message = (I18n.translate :too_long) and return false if self.query.length > MAX_QUERYTERM_LENGTH
    self.error_message = (I18n.translate :empty_query) and return false if self.query.blank?
    offset = self.page > 0 ? self.page * DEFAULT_PER_PAGE : 0
    if self.affiliate && !self.affiliate.domains.blank?
      sites = self.affiliate.domains.split("\n")
    else
      sites = ["gov", "mil"]
    end
    sites_str = sites.collect {|site| "site:#{site}"}.join(" OR ")
    sites_clause = "(#{sites_str})"
    language_clause = I18n.locale.to_s == "en" ? "" : "language:#{I18n.locale}"
    cleaned_query = self.query.strip
    q = "#{cleaned_query} #{sites_clause} #{language_clause}".strip

    begin
      uri = URI.parse("#{JSON_SITE}?web.offset=#{offset}&AppId=#{APP_ID}&sources=#{SOURCES}&Options=EnableHighlighting&query=#{URI.escape(q)}")
      resp = Net::HTTP.get_response(uri)
      body = translate_bing_highlights(resp.body)
      json = JSON.parse(body)
      response = ResponseData.new(json['SearchResponse'])

      self.total = response.web.total rescue 0
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
        self.related_search = BlockWord.filter(self.related_search, "Title")
      end
      self.results = WillPaginate::Collection.create(self.page+1, DEFAULT_PER_PAGE, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = self.page * DEFAULT_PER_PAGE + 1
      self.endrecord = self.startrecord + self.results.size - 1
      num_images = response.image.total rescue 0
      if num_images > 0
        self.images = response.image.results
      end
    rescue SocketError, Errno::ECONNREFUSED, JSON::ParserError => e
      RAILS_DEFAULT_LOGGER.warn "Error getting search results from Bing server: #{e}"
      return false
    end
    self.boosted_sites = BoostedSite.search_for(self.affiliate, cleaned_query) unless self.affiliate.nil?
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

  private
  def translate_bing_highlights(body)
    body.gsub(/\xEE\x80\x80/, '<strong>').gsub(/\xEE\x80\x81/, '</strong>')
  end

end