class Search
  include SearchEngineResponseDiagnostics
  include Pageable
  BLACKLISTED_QUERIES = ["search", "search our site", "*", "1", "what are you looking for?", "¿qué está buscando?"]
  COMMERCIAL_INDEX_MODULE_TAGS = %w(BWEB IMAG GWEB GIMAG).freeze

  class SearchError < RuntimeError;
  end

  MAX_QUERYTERM_LENGTH = 255

  attr_reader :query,
              :affiliate,
              :page,
              :per_page,
              :error_message,
              :total,
              :startrecord,
              :endrecord,
              :results,
              :spelling_suggestion,
              :spelling_suggestion_eligible,
              :queried_at_seconds,
              :module_tag,
              :modules,
              :normalized_results

  def initialize(options = {})
    @affiliate = options[:affiliate]
    @query = build_query(options)
    initialize_pageable_attributes options

    @results, @spelling_suggestion = [], nil
    @normalized_results = []
    @queried_at_seconds = Time.now.to_i
    @modules = []
    @spelling_suggestion_eligible = !SuggestionBlock.exists?(query: options[:query])
  end

  # This does your search.
  def run
    @error_message = (I18n.translate :too_long) and return false if @query.length > MAX_QUERYTERM_LENGTH
    @error_message = (I18n.translate :empty_query) and return false unless query_present_or_blank_ok? and !query_blacklisted?

    response = search
    handle_response(response)
    populate_additional_results
    log_serp_impressions
    response.nil? or response ? true : response
  end

  def query_present_or_blank_ok?
    @query.present? or allow_blank_query?
  end

  def query_blacklisted?
    BLACKLISTED_QUERIES.include?(@query.downcase)
  end

  def first_page?
    page == 1
  end

  def to_xml(options = {:indent => 0, :root => :search})
    to_hash.to_xml(options)
  end

  def as_json(options = {})
    to_hash
  end

  def to_hash
    if @error_message
      {error: @error_message}
    else
      hash = {total: @total,
              startrecord: @startrecord,
              endrecord: @endrecord,
              results: results_to_hash}
      hash.merge!(related: remove_strong(related_search)) if self.respond_to?(:related_search)
      hash
    end
  end

  def results_to_hash
    @results
  end

  def commercial_results?
    COMMERCIAL_INDEX_MODULE_TAGS.include? module_tag
  end

  protected

  # This does the search.  You get back a response object, which is handled in the handle_response method below.
  def search
  end

  # Set @total, @startrecord, @endrecord, and do anything else based on those values here
  def handle_response(response)
  end

  def assign_spelling_suggestion_if_eligible(suggestion)
    @spelling_suggestion = suggestion if @spelling_suggestion_eligible
  end

  # If you need to query anything else, do that here
  def populate_additional_results
  end

  def log_serp_impressions
  end

  # All search classes should be cache-able, so we need to implement a unique cache key for each search class
  def cache_key
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

  def build_query(options)
    advanced_query_options = options.slice(:query,
                                           :query_quote,
                                           :query_not,
                                           :query_or,
                                           :file_type,
                                           :site_excludes)
    builder = AdvancedQueryBuilder.new(@affiliate.site_domains.pluck(:domain),
                                       advanced_query_options)
    builder.build
  end
end
