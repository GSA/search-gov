# frozen_string_literal: true

module DocumentSearchable
  extend ActiveSupport::Concern

  FACET_FIELDS = %w[audience
                    changed
                    content_type
                    created
                    mime_type
                    searchgov_custom1
                    searchgov_custom2
                    searchgov_custom3
                    tags].freeze

  def build_search_params
    {
      language: @affiliate.locale,
      query: formatted_query,
      size: @limit || @per_page,
      offset: detect_offset
    }.merge!(date_filter_hash, facet_filter_hash).
      tap { |f| f.merge!(facet_includes) if @include_facets }
  end

  def facet_includes
    { include: "title,path,thumbnail_url,#{FACET_FIELDS.join(',')}" }
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

  def handle_response(response)
    return unless response && response.status == 200

    process_valid_response(response)
  end

  def process_valid_response(response)
    @total = response.metadata.total
    @next_offset = @offset + @limit if @next_offset_within_limit && @total > (@offset + @limit)
    post_processor = DocumentSearchPostProcessor.new(@enable_highlighting, response.results)
    post_processor.post_process_results
    process_metadata_values(response)
    process_pagination_values(post_processor, response)
  end

  def process_pagination_values(post_processor, response)
    @results = paginate(response.results)
    @normalized_results = process_data_for_redesign(post_processor)
    @normalized_results[:aggregations] = @aggregations if @include_facets
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
    DocumentSearchable::FACET_FIELDS.reject { |f| f == 'created' || result[f].nil? }.each_with_object({}) do |field, fields|
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

  def domains_scope_options
    DomainScopeOptionsBuilder.build(site: @affiliate,
                                    collection: collection,
                                    site_limits: @site_limits)
  end
end
