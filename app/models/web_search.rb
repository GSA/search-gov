class WebSearch < Search
  include SearchOnCommercialEngine
  include Govboxable

  attr_reader :matching_site_limits, :tracking_information

  def initialize(options = {})
    super(options)
    @options = options
    offset = (@page - 1) * @per_page
    formatted_query_instance = "#{@affiliate.search_engine.classify}FormattedQuery".constantize.new(@query, domains_scope_options)
    @matching_site_limits = formatted_query_instance.matching_site_limits
    @formatted_query = formatted_query_instance.query
    search_engine_parameters = options.merge(language: @affiliate.locale,
                                             offset: offset,
                                             per_page: @per_page,
                                             query: @formatted_query)
    @search_engine = search_engine_klass(@affiliate.search_engine).new(search_engine_parameters)
  end

  def cache_key
    [@formatted_query, @options.remove(:affiliate).merge(affiliate_id: @affiliate.id), @affiliate.search_engine].join(':')
  end

  def to_hash
    hash = super
    unless @error_message
      hash[:spelling_suggestion] = @spelling_suggestion if @spelling_suggestion
      hash[:boosted_results] = boosted_contents.results if has_boosted_contents?
      hash[:jobs] = jobs if jobs.present?
    end
    hash
  end

  def diagnostics_label
    module_tag_for_search_engine
  end

  protected

  def search_engine_klass(search_engine_option)
    "#{search_engine_option.classify}#{get_vertical.to_s.classify}Search".constantize
  end

  def domains_scope_options
    DomainScopeOptionsBuilder.build(site: @affiliate, site_limits: @options[:site_limits])
  end

  def handle_response(response)
    @total = begin
      response.total
    rescue
      0
    end
    available_search_engine_pages = (@total / @per_page.to_f).ceil
    handle_search_engine_response(response) if available_search_engine_pages >= @page
    assign_module_tag
  end



  def handle_search_engine_response(response)
    @startrecord = response.start_record
    @results = paginate(post_process_results(response.results))
    @endrecord = response.end_record
    assign_spelling_suggestion_if_eligible(response.spelling_suggestion)
    @tracking_information = response.tracking_information
  end



  def assign_module_tag
    @module_tag = nil
    return unless @total.positive?

    @module_tag = if @indexed_results.present?
                    local_index_module_tag
                  else
                    module_tag_for_search_engine
                  end
  end

  def local_index_module_tag
    'AIDOC'
  end

  def module_tag_for_search_engine
    'BWEB'
  end

  def post_process_results(results)
    post_processor = WebResultsPostProcessor.new(@query, @affiliate, results)
    @normalized_results = process_data_for_redesign(post_processor)
    post_processor.post_processed_results
  end

  def process_data_for_redesign(post_processor)
    post_processor.normalized_results(@total)
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(query, affiliate, @options[:geoip_info], site_limits: @matching_site_limits) if first_page?
  end

  def log_serp_impressions
    @modules << module_tag if module_tag
    @modules |= spelling_suggestion_modules
    @modules |= @govbox_set.modules if @govbox_set
  end

  def spelling_suggestion_modules
    return [] unless spelling_suggestion

    commercial_results? ? %w[OVER BSPEL] : %w[LOVER SPEL]
  end

  def get_vertical
    :web
  end

  def social_image_feeds_checked?
    true
  end
end
