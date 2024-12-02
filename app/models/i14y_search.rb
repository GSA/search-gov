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

  attr_reader :aggregations, :collection, :matching_site_limits

  def initialize(options = {})
    super
    @enable_highlighting = options[:enable_highlighting] != false
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
      size: @limit || @per_page,
      offset: detect_offset
    }.merge!(filter_options)

    I14yCollections.search(search_options)
  rescue Faraday::ClientError => e
    Rails.logger.error 'I14y search problem', e

    false
  end
  def filter_options
    options = {}.tap do |opts|
      opts.merge!(date_filter_hash, facet_filter_hash)
      opts[:ignore_tags] = @affiliate.tag_filters.excluded.pluck(:tag).join(',') if @affiliate.tag_filters.excluded.present?
      opts[:tags] = included_tags if @tags || @affiliate.tag_filters.required.present?
      opts[:include] = "title,path,thumbnail_url,#{FACET_FIELDS.join(',')}" if @include_facets
    end
  end

  def detect_offset
    @offset || ((@page - 1) * @per_page)
  end

  def first_page?
    @offset ? @offset.zero? : super
  end

  protected

  def date_filter_hash
    {}.tap do |opts|
      opts[:sort_by_date] = 1 if @sort_by == 'date'
      opts[:min_timestamp] = @since if @since
      opts[:max_timestamp] = @until if @until
      opts[:min_timestamp_created] = @created_since if @created_since
      opts[:max_timestamp_created] = @created_until if @created_until
    end
  end

  def facet_filter_hash
    {}.tap do |opts|
      %i[audience content_type mime_type searchgov_custom1 searchgov_custom2 searchgov_custom3].each do |field|
        opts[field] = instance_variable_get("@#{field}") if instance_variable_get("@#{field}")
      end
    end
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

    process_valid_response(response)
  end

  def process_valid_response(response)
    @total = response.metadata.total
    @next_offset = @offset + @limit if @next_offset_within_limit && @total > (@offset + @limit)
    post_processor = I14yPostProcessor.new(@enable_highlighting, response.results, @affiliate.excluded_urls_set)
    post_processor.post_process_results
    process_pagination_values(post_processor, response)
    process_metadata_values(response)
  end

  def process_pagination_values(post_processor, response)
    @results = paginate(response.results)
    @normalized_results = process_data_for_redesign(post_processor)
    @startrecord = ((@page - 1) * @per_page) + 1
    @endrecord = @startrecord + @results.size - 1
  end

  def process_metadata_values(response)
    @spelling_suggestion = response.metadata.suggestion.text if response.metadata.suggestion.present?
    @aggregations = response.metadata.aggregations if response.metadata.aggregations.present?
  end

  def result_url(result)
    result.link
  end

  def add_facets_to_results(result)
    I14ySearch::FACET_FIELDS.reject { |f| f == 'created' || result[f].nil? }.each_with_object({}) do |field, fields|
      field_key = field.to_sym == :changed ? :updated_date : field.to_sym
      field_value = field.to_sym == :changed ? result['changed'].to_date : result[field]
      fields[field_key] = field_value
    end
  end

  def process_data_for_redesign(post_processor)
    post_processor.normalized_results(@total)
  end

  def populate_additional_results
    @govbox_set = GovboxSet.new(query, affiliate, @options[:geoip_info], @highlight_options) if first_page?
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
