class I14ySearch < FilterableSearch
  include SearchInitializer
  include Govboxable
  I14Y_SUCCESS = 200
  FACET_FIELDS = %w[audience
                    changed
                    content_type
                    created
                    mime_type
                    searchgov_custom1
                    searchgov_custom2
                    searchgov_custom3
                    tags].freeze
  attr_reader :aggregations,
              :collection,
              :matching_site_limits

  def initialize(options = {})
    super
    @enable_highlighting = !(false === options[:enable_highlighting])
    @include_facets = options[:include_facets] == 'true'
    @collection = options[:document_collection]
    @site_limits = options[:site_limits]
    @matching_site_limits = formatted_query_instance.matching_site_limits
  end

  def search
    search_options = {
      handles: handles,
      language: @affiliate.locale,
      query: formatted_query,
      size: detect_size,
      offset: detect_offset
    }.merge!(filter_options)

    I14yCollections.search(search_options)
  rescue Faraday::ClientError => e
    Rails.logger.error "I14y search problem: #{e.message}"
    false
  end

  def filter_options
    filter_options = {}
    date_filter_options(filter_options)
    facet_filter_options(filter_options)
    filter_options[:ignore_tags] = @affiliate.tag_filters.excluded.pluck(:tag).join(',') if @affiliate.tag_filters.excluded.present?
    filter_options[:tags] = included_tags if @tags || @affiliate.tag_filters.required.present?
    include_facet_fields(filter_options) if @include_facets
    filter_options
  end

  def detect_size
    @limit || @per_page
  end

  def detect_offset
    @offset || ((@page - 1) * @per_page)
  end

  def first_page?
    @offset ? @offset.zero? : super
  end

  protected

  def include_facet_fields(filter_options)
    filter_options[:include] = "title,path,#{FACET_FIELDS.join(',')}"
  end

  def date_filter_options(filter_options)
    filter_options[:sort_by_date] = 1 if @sort_by == 'date'
    filter_options[:min_timestamp] = @since if @since
    filter_options[:max_timestamp] = @until if @until
  end

  def facet_filter_options(filter_options)
    filter_options[:audience] = @audience if @audience
    filter_options[:content_type] = @content_type if @content_type
    filter_options[:mime_type] = @mime_type if @mime_type
    filter_options[:searchgov_custom1] = @searchgov_custom1 if @searchgov_custom1
    filter_options[:searchgov_custom2] = @searchgov_custom2 if @searchgov_custom2
    filter_options[:searchgov_custom3] = @searchgov_custom3 if @searchgov_custom3
  end

  def included_tags
    tags = []
    tags << @affiliate.tag_filters.required.pluck(:tag) if @affiliate.tag_filters.required.present?
    tags << @tags if @tags
    tags.join(',')
  end

  def handles
    handles = []
    handles += @affiliate.i14y_drawers.pluck(:handle) if @affiliate.gets_i14y_results
    handles << 'searchgov' if affiliate.search_engine == 'SearchGov' || !@affiliate.gets_i14y_results
    handles.join(',')
  end

  def handle_response(response)
    return unless response && response.status == I14Y_SUCCESS

    @total = response.metadata.total
    I14yPostProcessor.new(@enable_highlighting,
                          response.results,
                          @affiliate.excluded_urls_set).post_process_results
    @results = paginate(response.results)
    @startrecord = ((@page - 1) * @per_page) + 1
    @endrecord = @startrecord + @results.size - 1
    @spelling_suggestion = response.metadata.suggestion.text if response.metadata.suggestion.present?
    @aggregations = response.metadata.aggregations if response.metadata.aggregations.present?
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(query, affiliate, @options[:geoip_info], **@highlight_options) if first_page?
  end

  def log_serp_impressions
    @modules |= @govbox_set.modules if @govbox_set
    @modules << 'I14Y' if @total.positive?
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build(site: @affiliate,
                                    collection: collection,
                                    site_limits: @site_limits)
  end

  def formatted_query
    formatted_query_instance.query
  end

  def formatted_query_instance
    @formatted_query_instance ||= I14yFormattedQuery.new(@query, domains_scope_options)
  end
end
