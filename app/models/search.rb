class Search
  attr_accessor :query, :page, :error_message, :affiliate, :total, :results, :startrecord, :endrecord, :related_search, :spelling_suggestion, :boosted_sites, :spotlight, :faqs, :gov_forms, :results_per_page, :index
  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  JSON_SITE="http://api.search.live.net/json.aspx"
  APP_ID="A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  SOURCES = %w{Spell Web RelatedSearch}.join('+')

  def initialize(options = {})
    options ||= {}
    self.query = options[:query] || ''
    self.affiliate = options[:affiliate]
    self.page = [options[:page].to_i, 0].max
    self.results_per_page = options[:results_per_page] || DEFAULT_PER_PAGE
    self.results, self.related_search, self.boosted_sites, self.faqs, self.gov_forms = [], [], nil, nil, nil
    self.index = options[:index]
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

    if !index
      return search_bing(q, cleaned_query, offset, sites_str, scope_clause, language_clause)
    elsif index == 'faqs'
      return search_faqs(cleaned_query)    
    elsif index == 'gov_forms'
      return search_gov_forms(cleaned_query)  
    else
      return false
    end
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
  
  def search_bing(q, cleaned_query, offset, sites_str, scope_clause, language_clause)
    begin
      uri = URI.parse("#{JSON_SITE}?web.offset=#{offset}&web.count=#{self.results_per_page}&AppId=#{APP_ID}&sources=#{SOURCES}&Options=EnableHighlighting&query=#{URI.escape(q)}")
      resp = Net::HTTP.get_response(uri)
      body = translate_bing_highlights(resp.body)
      json = JSON.parse(body)
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
    rescue SocketError, Errno::ECONNREFUSED, JSON::ParserError => e
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
  
  def search_faqs(cleaned_query)
    begin
      faq_search_results = Faq.search_for(cleaned_query, self.page + 1, self.results_per_page)
      self.total = faq_search_results.total
      if self.total > 0
        results_array = faq_search_results.hits.collect do |hit|
          {'title' => hit.instance.question,
           'unescapedUrl'=> hit.instance.url,
           'content'=> (hit.instance.answer rescue ""),
           'cacheUrl'=> "",
           'deepLinks' => []
          }
        end
      end
      pagination_total = [self.results_per_page * 20, self.total ].min
      self.results = WillPaginate::Collection.create(self.page + 1, self.results_per_page, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = self.page * self.results_per_page + 1
      self.endrecord = self.startrecord + self.results.size - 1
    rescue => e
      RAILS_DEFAULT_LOGGER.warn "Error getting search results for Faqs: #{e}"
      return false
    end
    true
  end
  
  def search_gov_forms(cleaned_query)
    begin
      gov_form_search_results = GovForm.search_for(cleaned_query, self.page + 1, self.results_per_page)
      self.total = gov_form_search_results.total
      if self.total > 0
        results_array = gov_form_search_results.hits.collect do |hit|
          {'title' => "#{hit.instance.name} - #{hit.instance.form_number}",
           'unescapedUrl'=> hit.instance.url,
           'content'=> ("#{hit.instance.agency} - #{hit.instance.description}" rescue ""),
           'cacheUrl'=> "",
           'deepLinks' => []
          }
        end
      end
      pagination_total = [self.results_per_page * 20, self.total ].min
      self.results = WillPaginate::Collection.create(self.page + 1, self.results_per_page, pagination_total) { |pager| pager.replace(results_array) }
      self.startrecord = self.page * self.results_per_page + 1
      self.endrecord = self.startrecord + self.results.size - 1    
    rescue => e
      RAILS_DEFAULT_LOGGER.warn "Error getting search results for GovForms: #{e}"
      return false
    end
    true
  end
  
  def translate_bing_highlights(body)
    body.gsub(/\xEE\x80\x80/, '<strong>').gsub(/\xEE\x80\x81/, '</strong>')
  end

end
