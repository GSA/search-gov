# TODO Cleanup
class Search
  class BingSearchError < RuntimeError;
  end

  MAX_QUERY_LENGTH_FOR_ITERATIVE_SEARCH = 30
  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50
  JSON_SITE = "http://api.search.live.net/json.aspx"
  APP_ID = "A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  SOURCES = "Spell+Web+RelatedSearch"
  USER_AGENT = "USASearch"
  CLIENT_IP = "209.251.180.16"
  DEFAULT_SCOPE = "(scopeid:usagovall OR site:gov OR site:mil)"
  DEFAULT_FILTER_SETTING = 'strict'
  URI_REGEX = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")

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
                :results_per_page,
                :filter_setting,
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
    self.scope_id = options[:fedstates] || nil
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
      self.related_search = related_search_results(response)
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

  def self.suggestions(sanitized_query, num_suggestions = 15)
    query = sanitized_query.clone
    corrected_query = Misspelling.correct(query)
    corrected_suggestions = corrected_query != query ? SaytSuggestion.like(corrected_query, num_suggestions) : []
    suggestions = SaytSuggestion.like(query, num_suggestions) || []
    (corrected_suggestions + suggestions)[0, num_suggestions]
  end

  private

  def log_impression
    modules = []
    modules << "BWEB" unless self.total.zero?
    modules << "BSPEL" unless self.spelling_suggestion.nil?
    modules << "BREL" unless self.related_search.nil? or self.related_search.empty?
    modules << "FAQS" unless self.faqs.nil? or self.faqs.total.zero?
    modules << "FORM" unless self.gov_forms.nil? or self.gov_forms.total.zero?
    modules << "SPOT" unless self.spotlight.nil?
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
      "Adult=#{self.filter_setting.blank? ? DEFAULT_FILTER_SETTING : self.filter_setting}",
      "query=#{URI.escape(query_string, URI_REGEX)}"
    ]
    "#{JSON_SITE}?" + params.join('&')
  end

  protected

  def related_search_results(response)
    begin
      BlockWord.filter(response.related_search.results, "Title", 5)
    rescue
      return []
    end
  end

  def spelling_results(response)
    response.spell.results.first.value.split(/ \(scopeid/).first.gsub(/<\/?[^>]*>/, '').chomp(')').reverse.chomp('(').reverse rescue nil
  end

  def populate_additional_results
    if affiliate
      self.boosted_sites = BoostedSite.search_for(affiliate, query)
    elsif english_locale?
      self.spotlight = Spotlight.search_for(query)
      self.faqs = Faq.search_for(query)
      self.gov_forms = GovForm.search_for(query)
    end
    if query =~ /\brecalls?\b/i and not query=~ /^recalls?$/i
      begin
        self.recalls = Recall.search_for(query.gsub(/\brecalls?\b/i, '').strip, {:start_date=>1.month.ago.to_date, :end_date=>Date.today})
      rescue RSolr::RequestError => error
        RAILS_DEFAULT_LOGGER.warn "Error in searching for Recalls: #{error.to_s}"
        self.recalls = nil
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
        req["Client-IP"] = CLIENT_IP
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
    if !options[:query].blank?
      query += options[:query].split.collect { |term| limit_field(options[:query_limit], term) }.join(' ')
    end

    if !options[:query_quote].blank?
      query += ' ' + limit_field(options[:query_quote_limit], "\"#{options[:query_quote]}\"")
    end

    if !options[:query_or].blank?
      query += ' ' + options[:query_or].split.collect { |term| limit_field(options[:query_or_limit], term) }.join(' OR ')
    end

    if !options[:query_not].blank?
      query += ' ' + options[:query_not].split.collect { |term| "-#{limit_field(options[:query_not_limit], term)}" }.join(' ')
    end

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
    elsif self.scope_id && !self.scope_id.empty? && self.scope_id != 'all'
      "(scopeid:usagov#{self.scope_id})"
    else
      DEFAULT_SCOPE
    end
  end

  def affiliate_scope
    return unless affiliate_scope?
    scope = affiliate.domains.split("\n").collect { |site| "site:#{site}" }.join(" OR ")
    "(#{scope})"
  end

  def affiliate_scope?
    affiliate && affiliate.domains.present? && query !~ /site:/
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
end
