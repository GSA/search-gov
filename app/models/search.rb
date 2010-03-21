# TODO Cleanup
class Search
  class BingSearchError < RuntimeError;
  end

  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50
  JSON_SITE = "http://api.search.live.net/json.aspx"
  APP_ID = "A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  SOURCES = "Spell+Web+RelatedSearch"
  USER_AGENT = "USASearch"
  CLIENT_IP = "209.251.180.16"
  DEFAULT_SCOPE = "(scopeid:usagovall OR site:.gov OR site:.mil)"
  DEFAULT_FILTER_SETTING = 'strict'

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
                :results_per_page,
                :filter_setting,
                :scope_id

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
  end

  def run
    self.error_message = (I18n.translate :too_long) and return false if query.length > MAX_QUERYTERM_LENGTH
    self.error_message = (I18n.translate :empty_query) and return false if query.blank?

    begin
      response = parse(perform(formatted_query, offset))
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
    true
  end

  private

  def hits(response)
    (response.web.results.empty? ? 0 : response.web.total) rescue 0
  end

  def process_results(response)
    processed = response.web.results.collect do |result|
      {
        'title'         => (result.title rescue nil),
        'unescapedUrl'  => result.url,
        'content'       => (result.description rescue nil),
        'cacheUrl'      => (result.CacheUrl rescue nil),
        'deepLinks'     => result["DeepLinks"]
      }
    end
    processed.reject { |hash| hash['title'].blank? or hash['content'].blank? }
  end

  def bing_query(query_string, offset, count)
    params = [
      "web.offset=#{offset}",
      "web.count=#{count}",
      "AppId=#{APP_ID}",
      "sources=#{SOURCES}",
      "Options=EnableHighlighting",
      "Adult=#{self.filter_setting.blank? ? DEFAULT_FILTER_SETTING : self.filter_setting}",
      "query=#{URI.escape(query_string)}"
    ]
    "#{JSON_SITE}?" + params.join('&')
  end

  def self.suggestions(sanitized_query, num_suggestions = 15)
    SaytSuggestion.find(:all, :conditions => ['phrase LIKE ? ', sanitized_query + '%' ], :order => 'phrase ASC', :limit => num_suggestions, :select=>"distinct(phrase) as phrase")
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
    response.spell.results.first.value.split(/ \(scopeid/).first.gsub(/<\/?[^>]*>/, '') rescue nil
  end

  def populate_additional_results
    if affiliate
      self.boosted_sites = BoostedSite.search_for(affiliate, query)
    elsif english_locale?
      self.spotlight = Spotlight.search_for(query)
      self.faqs = Faq.search_for(query)
      self.gov_forms = GovForm.search_for(query)
    end
  end

  def paginate(items)
    pagination_total = [results_per_page * 20, total].min
    WillPaginate::Collection.create(page + 1, results_per_page, pagination_total) { |pager| pager.replace(items) }
  end

  def perform(query_string, offset)
    ActiveRecord::Base.benchmark("Performing Bing Search") do
      begin
        uri = URI.parse(bing_query(query_string, offset, results_per_page))
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
      query += options[:query].split.collect{ |term| limit_field(options[:query_limit], term) }.join(' ')
    end

    if !options[:query_quote].blank?
      query += ' ' + limit_field(options[:query_quote_limit], "\"#{options[:query_quote]}\"")
    end

    if !options[:query_or].blank?
      query += ' ' + options[:query_or].split.collect{ |term| limit_field(options[:query_or_limit], term) }.join(' OR ')
    end

    if !options[:query_not].blank?
      query += ' ' + options[:query_not].split.collect{ |term| "-#{limit_field(options[:query_not_limit], term)}"}.join(' ')
    end

    query += " filetype:#{options[:file_type]}" unless options[:file_type].blank? || options[:file_type].downcase == 'all'
    query += " #{options[:site_limits].split.collect { |site| 'site:' + site}.join(' OR ')}" unless options[:site_limits].blank?
    query += " #{options[:site_excludes].split.collect { |site| '-site:' + site}.join(' ')}" unless options[:site_excludes].blank?
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
    elsif self.scope_id  && !self.scope_id.empty? && self.scope_id != 'all'
      "(scopeid:usagov#{self.scope_id})"
    else
      DEFAULT_SCOPE
    end
  end

  def affiliate_scope
    return unless affiliate_scope?
    scope = affiliate.domains.split("\n").collect {|site| "site:#{site}"}.join(" OR ")
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
    "#{query} #{scope} #{locale}".strip.squeeze(' ')
  end
end
