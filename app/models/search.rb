class Search
  class SearchError < RuntimeError;
  end

  @@redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)

  MAX_QUERY_LENGTH_FOR_ITERATIVE_SEARCH = 30
  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50
  USER_AGENT = "USASearch"
  QUERY_STRING_ALLOCATION = 1800
  URI_REGEX = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")

  attr_reader :query,
              :affiliate,
              :page,
              :per_page,
              :error_message,
              :total,
              :startrecord,
              :endrecord,
              :results,
              :related_search,
              :spelling_suggestion,
              :queried_at_seconds

  def initialize(options = {})
    @options = options
    @query = build_query(options)
    @affiliate = options[:affiliate]
    @page = (options[:page] || 1)
    @per_page = [(options[:per_page] || DEFAULT_PER_PAGE), MAX_PER_PAGE].min
    @related_search, @results, @spelling_suggestion = [], [], nil
    @queried_at_seconds = Time.now.to_i
  end

  # Override this method to process various different options and augment the query string
  def build_query(options)
    options[:query]
  end

  # This does your search.
  def run
    @error_message = (I18n.translate :too_long) and return false if @query.length > MAX_QUERYTERM_LENGTH
    @error_message = (I18n.translate :empty_query) and return false unless @query.present? or allow_blank_query?

    response = search
    handle_response(response)
    populate_additional_results
    log_serp_impressions
    response.nil? or response ? true : response
  end

  def first_page?
    page == 1
  end

  def has_related_searches?
    @related_search && @related_search.size > 0
  end

  def as_json(options = {})
    result_hash
  end

  def to_xml(options = {:indent => 0, :root => :search})
    result_hash.to_xml(options)
  end

  def result_hash
    if @error_message
      {:error => @error_message}
    else
      hash = {:total => @total, :startrecord => @startrecord, :endrecord => @endrecord, :results => @results}
      hash.merge!(:related => remove_strong(@related_search))
      hash
    end
  end

  protected

  # This does the search.  You get back a response object, which is handled in the handle_response method below.
  def search
  end

  # Set @total, @startrecord, @endrecord, and do anything else based on those values here
  def handle_response(response)
  end

  # If you need to query anything else, do that here
  def populate_additional_results
    @related_search = SaytSuggestion.related_search(@query, @affiliate)
  end

  def log_serp_impressions
  end

  # All search classes should be cache-able, so we need to implement a unique cache key for each search class
  def cache_key
  end

  # This is used any time we want to highlight something
  def highlight_solr_hit_like_bing(hit, field_symbol)
    return hit.highlights(field_symbol).first.format { |phrase| "\xEE\x80\x80#{phrase}\xEE\x80\x81" } unless hit.highlights(field_symbol).first.nil?
    hit.instance.send(field_symbol)
  end

  def paginate(items)
    WillPaginate::Collection.create(@page, @per_page, [@per_page * 100, @total].min) { |pager| pager.replace(items) }
  end

  def allow_blank_query?
    false
  end

  def remove_strong(string_array)
    string_array.map { |entry| entry.gsub(/<\/?strong>/, '') } if string_array.kind_of?(Array)
  end

end