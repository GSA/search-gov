class Search
  attr_accessor :query, :page, :error_message, :affiliate, :total, :results, :startrecord, :endrecord, :related_search, :spelling_suggestion, :boosted_sites, :spotlight, :faqs, :gov_forms, :results_per_page
  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50
  JSON_SITE="http://api.search.live.net/json.aspx"
  APP_ID="A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  SOURCES = %w{Spell Web RelatedSearch}.join('+')

  def initialize(options = {})
    options ||= {}
    self.query = build_query(options)
    self.affiliate = options[:affiliate]
    self.page = [options[:page].to_i, 0].max
    self.results_per_page = options[:results_per_page] || DEFAULT_PER_PAGE
    self.results_per_page = self.results_per_page.to_i unless self.results_per_page.is_a?(Integer)
    if self.results_per_page > MAX_PER_PAGE
      self.results_per_page = MAX_PER_PAGE
    end
    self.results, self.related_search, self.boosted_sites, self.faqs, self.gov_forms = [], [], nil, nil, nil
  end
  
  def build_query(options)
    query = ''
    if !options[:query].nil? && !options[:query].empty?
      query += limit_field(options[:query_limit], options[:query])
    end
    
    if !options[:query_quote].nil? && !options[:query_quote].empty?
      query += ' '
      query += limit_field(options[:query_quote_limit], "\"#{options[:query_quote]}\"")
    end
    
    if !options[:query_or].nil? && !options[:query_or].empty?
      query_or = options[:query_or].split.join(' OR ')
      query += ' ' + limit_field(options[:query_or_limit], query_or)
    end
    
    if !options[:query_not].nil? && !options[:query_not].empty?
      query_not = '-' + options[:query_not].split.join(' -')
      query += ' ' + limit_field(options[:query_not_limit], query_not)
    end
   
    query += " filetype:#{options[:file_type]}" unless options[:file_type].nil? || options[:file_type].empty? || options[:file_type].downcase == 'all'
    query += " #{options[:site_limits].split.collect { |site| 'site:' + site}.join(' OR ')}" unless options[:site_limits].nil? || options[:site_limits].empty?
    query += " #{options[:site_excludes].split.collect { |site| '-site:' + site}.join(' ')}" unless options[:site_excludes].nil? || options[:site_excludes].empty?
    return query.strip
  end
  
  def limit_field(field_name, query)
    if field_name.nil?
      query
    else
      if field_name.empty?
        query
      else
        "#{field_name}(#{query})"
      end
    end
  end
  
  def run
    self.error_message = (I18n.translate :too_long) and return false if self.query.length > MAX_QUERYTERM_LENGTH
    self.error_message = (I18n.translate :empty_query) and return false if self.query.blank?
    offset = self.page > 0 ? self.page * self.results_per_page : 0
    if self.affiliate && !self.affiliate.domains.blank? && !self.query.match(/site:/)
      sites_str = self.affiliate.domains.split("\n").collect {|site| "site:#{site}"}.join(" OR ")
      scope_clause = "(#{sites_str})"
    else
      scope_clause = "(scopeid:usagovall OR site:.gov OR site:.mil)"
    end
    language_clause = I18n.locale.to_s == "en" ? "" : "language:#{I18n.locale}"
    cleaned_query = self.query.strip
    q = "#{cleaned_query} #{scope_clause} #{language_clause}".strip.squeeze(' ')

    begin
      uri = URI.parse("#{JSON_SITE}?web.offset=#{offset}&web.count=#{self.results_per_page}&AppId=#{APP_ID}&sources=#{SOURCES}&Options=EnableHighlighting&query=#{URI.escape(q)}")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Get.new(uri.request_uri)
      req["User-Agent"] = "USASearch"
      req["Client-IP"] = "209.251.180.16"
      resp = http.request(req)
      json = JSON.parse(resp.body)
      response = ResponseData.new(json['SearchResponse'])

      self.total = response.web.total rescue 0
      self.spelling_suggestion = response.spell.results.first.value.split(/ \(scopeid/).first.gsub(/<\/?[^>]*>/, '') rescue nil
      pagination_total = [self.results_per_page * 20, self.total ].min
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
      self.results = WillPaginate::Collection.create(self.page+1, self.results_per_page, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = self.page * self.results_per_page + 1
      self.endrecord = self.startrecord + self.results.size - 1
    rescue SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET, JSON::ParserError => e
      RAILS_DEFAULT_LOGGER.warn "Error getting search results from Bing server: #{e}"
      return false
    end
    if self.affiliate.nil?
      if I18n.locale.to_s == 'en'
        self.spotlight = Spotlight.search_for(cleaned_query)
        self.faqs = Faq.search_for(cleaned_query)
        self.gov_forms = GovForm.search_for(cleaned_query)
      end
    else
      self.boosted_sites = BoostedSite.search_for(self.affiliate, cleaned_query)
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
