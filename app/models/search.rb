# TODO Cleanup
class Search
  class BingSearchError < RuntimeError;
  end

  MAX_QUERY_LENGTH_FOR_ITERATIVE_SEARCH = 30
  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50
  JSON_SITE = "http://api.bing.net/json.aspx"
  APP_ID = "A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  SOURCES = "Spell+Web"
  USER_AGENT = "USASearch"
  DEFAULT_SCOPE = "(scopeid:usagovall OR site:gov OR site:mil)"
  VALID_FILTER_VALUES = %w{strict off}
  DEFAULT_FILTER_SETTING = 'strict'
  URI_REGEX = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
  VALID_SCOPES = %w{ PatentClass }

  attr_accessor :query,
                :page,
                :error_message,
                :affiliate,
                :total,
                :results,
                :startrecord,
                :endrecord,
                :images,
                :related_search,
                :spelling_suggestion,
                :boosted_sites,
                :spotlight,
                :faqs,
                :gov_forms,
                :recalls,
                :weather_spotlight,
                :results_per_page,
                :filter_setting,
                :fedstates,
                :scope_id,
                :queried_at_seconds,
                :enable_highlighting

  def initialize(options = {})
    options ||= {}
    self.query = build_query(options)
    self.affiliate = options[:affiliate]
    self.page = [options[:page].to_i, 0].max
    self.results_per_page = options[:results_per_page] || DEFAULT_PER_PAGE
    self.results_per_page = self.results_per_page.to_i unless self.results_per_page.is_a?(Integer)
    self.results_per_page = MAX_PER_PAGE if results_per_page > MAX_PER_PAGE
    self.fedstates = options[:fedstates] || nil
    self.scope_id = options[:scope_id] || nil
    self.filter_setting = options[:filter] || nil
    self.results, self.related_search = [], []
    self.queried_at_seconds = Time.now.to_i
    self.enable_highlighting = options[:enable_highlighting].nil? ? true : options[:enable_highlighting]
  end

  def run
    self.error_message = (I18n.translate :too_long) and return false if query.length > MAX_QUERYTERM_LENGTH
    self.error_message = (I18n.translate :empty_query) and return false if query.blank?

    begin
      response = parse(perform(formatted_query, offset, enable_highlighting))
    rescue BingSearchError => error
      RAILS_DEFAULT_LOGGER.warn "Error getting search results from Bing server: #{error}"
      return false
    end

    self.total = hits(response)
    unless total.zero?
      self.results = paginate(process_results(response))
      self.spelling_suggestion = spelling_results(response)
      self.related_search = related_search_results
      self.startrecord = page * results_per_page + 1
      self.endrecord = startrecord + results.size - 1
      populate_additional_results
    end
    log_impression
    true
  end

  def as_json(options = {})
    if self.error_message
      {:error => self.error_message}
    else
      {:total => self.total, :startrecord => self.startrecord, :endrecord => self.endrecord, :spelling_suggestions => self.spelling_suggestion, :related => self.related_search, :results => self.results}
    end
  end

  def self.suggestions(affiliate_id, sanitized_query, num_suggestions = 15)
    corrected_query = Misspelling.correct(sanitized_query)
    suggestions = SaytSuggestion.like(affiliate_id, corrected_query, num_suggestions) || []
    suggestions[0, num_suggestions]
  end

  protected

  def related_search_results
    affiliate_id = self.affiliate.nil? ? nil : self.affiliate.id
    if (affiliate_id)
      solr = CalaisRelatedSearch.search_for(self.query, I18n.locale.to_s, affiliate_id)
    end
    solr = CalaisRelatedSearch.search_for(self.query, I18n.locale.to_s) unless solr && solr.hits.present?
    related_terms = solr.hits.first.instance.related_terms rescue ""
    related_terms_array = related_terms.split('|')
    related_terms_array.each{|t| t.strip!}
    related_terms_array.delete(self.query)
    related_terms_array.sort! {|x,y| y.length <=> x.length }
    return related_terms_array[0,5].sort
  end

  def spelling_results(response)
    did_you_mean_suggestion = response.spell.results.first.value rescue nil
    strip_extra_chars_from(did_you_mean_suggestion)
  end

  def populate_additional_results
    self.boosted_sites = BoostedSite.search_for(query, affiliate, I18n.locale)
    unless affiliate
      self.faqs = Faq.search_for(query, I18n.locale.to_s)
      if english_locale?
        self.spotlight = Spotlight.search_for(query)
        self.gov_forms = GovForm.search_for(query)
      end
    end
    if query =~ /\brecalls?\b/i and not query=~ /^recalls?$/i
      begin
        self.recalls = Recall.search_for(query.gsub(/\brecalls?\b/i, '').strip, {:start_date=>1.month.ago.to_date, :end_date=>Date.today})
      rescue RSolr::RequestError => error
        RAILS_DEFAULT_LOGGER.warn "Error in searching for Recalls: #{error.to_s}"
        self.recalls = nil
      end
    end
    if affiliate.nil? and WeatherSpotlight.is_weather_spotlight_query(query)
      ActiveRecord::Base.benchmark("[Weather Search]", Logger::INFO) do
        begin
          self.weather_spotlight = WeatherSpotlight.new(WeatherSpotlight.parse_query(query))
        rescue RuntimeError, Errno::ETIMEDOUT => error
          RAILS_DEFAULT_LOGGER.warn "Error in search for Weather: #{error.to_s}"
          self.weather_spotlight = nil
        end
      end
    end
  end

  def paginate(items)
    pagination_total = [results_per_page * 20, total].min
    WillPaginate::Collection.create(page + 1, results_per_page, pagination_total) { |pager| pager.replace(items) }
  end

  def perform(query_string, offset, enable_highlighting = true)
    ActiveRecord::Base.benchmark("[Bing Search]", Logger::INFO) do
      begin
        uri = URI.parse(bing_query(query_string, offset, results_per_page, enable_highlighting))
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Get.new(uri.request_uri)
        req["User-Agent"] = USER_AGENT
        http.request(req)
      rescue SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ENETUNREACH, Timeout::Error => error
        raise BingSearchError.new(error.to_s)
      end
    end
  end

  def parse(response)
    begin
      json = JSON.parse(response.body)
      ResponseData.new(json['SearchResponse'])
    rescue JSON::ParserError => error
      raise BingSearchError.new(error.to_s)
    end
  end

  def build_query(options)
    query = ''
    if options[:query].present?
      options[:query].downcase! if options[:query][-3,options[:query].size] == " OR"
      query += options[:query].split.collect { |term| limit_field(options[:query_limit], term) }.join(' ')
    end

    if options[:query_quote].present?
      query += ' ' + limit_field(options[:query_quote_limit], "\"#{options[:query_quote]}\"")
    end

    if options[:query_or].present?
      query += ' ' + options[:query_or].split.collect { |term| limit_field(options[:query_or_limit], term) }.join(' OR ')
    end

    if options[:query_not].present?
      query += ' ' + options[:query_not].split.collect { |term| "-#{limit_field(options[:query_not_limit], term)}" }.join(' ')
    end
    # query += " (scopeid:usagov#{options[:fedstates]})" unless options[:fedstates].blank? || options[:fedstates].downcase == 'all'
    query += " filetype:#{options[:file_type]}" unless options[:file_type].blank? || options[:file_type].downcase == 'all'
    query += " #{options[:site_limits].split.collect { |site| 'site:' + site }.join(' OR ')}" unless options[:site_limits].blank?
    query += " #{options[:site_excludes].split.collect { |site| '-site:' + site }.join(' ')}" unless options[:site_excludes].blank?
    return query.strip
  end

  def limit_field(field_name, term)
    if field_name.blank?
      term
    else
      "#{field_name}#{term}"
    end
  end

  def offset
    page * results_per_page
  end

  def scope
    if affiliate_scope
      affiliate_scope
    elsif self.fedstates && !self.fedstates.empty? && self.fedstates != 'all'
      "(scopeid:usagov#{self.fedstates})"
    else
      DEFAULT_SCOPE
    end
  end

  def affiliate_scope
    return unless affiliate_scope?
    if valid_scope_id?
      "(scopeid:#{self.scope_id}) #{DEFAULT_SCOPE}"
    else
      scope = affiliate.domains.split("\n").collect { |site| "site:#{site}" }.join(" OR ")
      "(#{scope})"
    end
  end

  def affiliate_scope?
    affiliate && ((affiliate.domains.present? && query !~ /site:/) || valid_scope_id?)
  end

  def valid_scope_id?
    self.scope_id.present? && VALID_SCOPES.include?(self.scope_id)
  end

  def english_locale?
    I18n.locale.to_s == 'en'
  end

  def locale
    return if english_locale?
    "language:#{I18n.locale}"
  end

  def formatted_query
    "(#{query}) #{scope} #{locale}".strip.squeeze(' ')
  end

  private

  def log_impression
    modules = []
    modules << "BWEB" unless self.total.zero?
    modules << "BSPEL" unless self.spelling_suggestion.nil?
    modules << "CREL" unless self.related_search.nil? or self.related_search.empty?
    modules << "FAQS" unless self.faqs.nil? or self.faqs.total.zero?
    modules << "FORM" unless self.gov_forms.nil? or self.gov_forms.total.zero?
    modules << "SPOT" unless self.spotlight.nil?
    modules << "WEAT" unless self.weather_spotlight.nil?
    modules << "BOOS" unless self.boosted_sites.nil? or self.boosted_sites.total.zero?
    RAILS_DEFAULT_LOGGER.info("[Search Impression] time: #{Time.now.to_formatted_s(:db)} , query: #{self.query}, modules: #{modules.inspect}")
  end

  def hits(response)
    (response.web.results.empty? ? 0 : response.web.total) rescue 0
  end

  def process_results(response)
    processed = response.web.results.collect do |result|
      title = result.title rescue nil
      content = result.description rescue ''
      if title.present?
        {
          'title'         => title,
          'unescapedUrl'  => result.url,
          'content'       => content,
          'cacheUrl'      => (result.CacheUrl rescue nil),
          'deepLinks'     => result["DeepLinks"]
        }
      else
        nil
      end
    end
    processed.compact
  end

  def bing_query(query_string, offset, count, enable_highlighting = true)
    params = [
      "web.offset=#{offset}",
      "web.count=#{count}",
      "AppId=#{APP_ID}",
      "sources=#{SOURCES}",
      "Options=#{ enable_highlighting ? "EnableHighlighting" : ""}",
      "Adult=#{adult_filter_setting}",
      "query=#{URI.escape(query_string, URI_REGEX)}"
    ]
    "#{JSON_SITE}?" + params.join('&')
  end

  def adult_filter_setting
    self.filter_setting.blank? ? DEFAULT_FILTER_SETTING : VALID_FILTER_VALUES.include?(self.filter_setting) ? self.filter_setting : DEFAULT_FILTER_SETTING
  end

  def strip_extra_chars_from(did_you_mean_suggestion)
    did_you_mean_suggestion.split(/ \(scopeid/).first.gsub(/[()]/, '').strip.squish unless did_you_mean_suggestion.nil?
  end

end
