class I14ySearch < FilterableSearch
  include SearchInitializer
  include Govboxable
  I14Y_SUCCESS = 200

  def initialize(options = {})
    super
    @enable_highlighting = !(false === options[:enable_highlighting])
  end

  def search
    search_options = {
      handles: handles,
      language: @affiliate.locale,
      query: formatted_query,
      size: detect_size,
      offset: detect_offset,
    }.merge!(filter_options)
    I14yCollections.search(search_options)
  rescue Faraday::ClientError => e
    Rails.logger.error "I14y search problem: #{e.message}"
    false
  end

  def filter_options
    filter_options = { }
    filter_options[:sort_by_date] = 1 if @sort_by == 'date'
    filter_options[:min_timestamp] = @since if @since
    filter_options[:max_timestamp] = @until if @until
    filter_options[:ignore_tags] = @affiliate.tag_filters.excluded.pluck(:tag).sort.join(',') if @affiliate.tag_filters.excluded.present?
    filter_options[:tags] = @affiliate.tag_filters.required.pluck(:tag).sort.join(',') if @affiliate.tag_filters.required.present?
    filter_options
  end

  def detect_size
    @limit ? @limit : @per_page
  end

  def detect_offset
    @offset ? @offset : ((@page - 1) * @per_page)
  end

  def first_page?
    @offset ? @offset.zero? : super
  end

  protected

  def handles
    handles = []
    handles += @affiliate.i14y_drawers.pluck(:handle) if @affiliate.gets_i14y_results
    handles << 'searchgov' if affiliate.search_engine == 'SearchGov'
    handles.join(',')
  end

  def handle_response(response)
    if response && response.status == I14Y_SUCCESS
      @total = response.metadata.total
      I14yPostProcessor.new(@enable_highlighting,
                            response.results,
                            @affiliate.excluded_urls_set).post_process_results
      @results = paginate(response.results)
      @startrecord = ((@page - 1) * @per_page) + 1
      @endrecord = @startrecord + @results.size - 1
      @spelling_suggestion = response.metadata.suggestion.text if response.metadata.suggestion.present?
    end
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(@spelling_suggestion || query,
                                affiliate,
                                @options[:geoip_info],
                                @highlight_options) if first_page?
  end


  def log_serp_impressions
    @modules |= @govbox_set.modules if @govbox_set
    @modules << 'I14Y' if @total > 0
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build @affiliate, nil
  end

  def formatted_query
    I14yFormattedQuery.new(@query, domains_scope_options).query
  end
end
