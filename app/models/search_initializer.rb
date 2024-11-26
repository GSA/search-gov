module SearchInitializer
  include Api::V2::NonCommercialSearch

  def initialize(options)
    super
    @options = options
    @query = (@query || '').squish
    @total = 0
    @limit = options[:limit]
    @offset = options[:offset]
    @highlight_options = options.slice(:pre_tags, :post_tags)
    @highlight_options[:highlighting] = options[:enable_highlighting]
  end

  protected

  def result_url(result)
    result.link
  end

  def as_json_result_hash(result)
    base_hash = super.merge(thumbnail_url: result.thumbnail_url)
    @include_facets ? base_hash.merge(add_facets_to_results(result)) : base_hash
  end

  def add_facets_to_results(result)
    I14ySearch::FACET_FIELDS.each_with_object({}) do |field, fields|
      next if field == 'created' || result[field].nil?

      process_facet_fields(fields, field.to_sym, result)
    end
  end

  def process_facet_fields(fields, field, result)
    field_key = field == :changed ? :updated_date : field
    field_value = field == :changed ? result['changed'].to_date : result[field.to_s]

    fields[field_key] = field_value
  end
end
