class Search
  class SearchError < RuntimeError;
  end

  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50

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
              :queried_at_seconds,
              :module_tag,
              :geoip_info

  def initialize(options = {})
    #TODO: need options?
    @options = options
    @query = options[:query]
    @affiliate = options[:affiliate]

    @page = options[:page].to_i rescue DEFAULT_PAGE
    @page = DEFAULT_PAGE unless @page >= DEFAULT_PAGE

    @per_page = options[:per_page].to_i rescue DEFAULT_PER_PAGE
    @per_page = DEFAULT_PER_PAGE unless (DEFAULT_PER_PAGE..MAX_PER_PAGE).include?(@per_page)

    @related_search, @results, @spelling_suggestion = [], [], nil
    @queried_at_seconds = Time.now.to_i
    @geoip_info = options[:geoip_info]
  end

  # This does your search.
  def run
    #TODO: can't this happen as part of validation when Engine initialized?
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

  # This is used any time we want to highlight a hit from Solr with the highlight chars that Bing uses
  def highlight_solr_hit_like_bing(hit, field_symbol)
    return hit.highlights(field_symbol).first.format { |phrase| "\uE000#{phrase}\uE001" } unless hit.highlights(field_symbol).first.nil?
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