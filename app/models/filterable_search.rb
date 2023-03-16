class FilterableSearch < Search
  TIME_FILTER_PARAMS = %i[hour day week month year].freeze
  TIME_BASED_SEARCH_OPTIONS = TIME_FILTER_PARAMS.index_by { |p| p.to_s[0] }

  class_attribute :default_sort_by
  self.default_sort_by = 'r'.freeze

  attr_reader :audience,
              :content_type,
              :created_since,
              :created_until,
              :mime_type,
              :searchgov_custom1,
              :searchgov_custom2,
              :searchgov_custom3,
              :since,
              :sort,
              :sort_by,
              :tags,
              :tbs,
              :until

  def initialize(options)
    super
    initialize_date_attributes(options)
    initialize_facet_attributes(options)
    @sort_by = options[:sort_by] if %w[date r].include?(options[:sort_by])
    @sort = 'published_at:desc' unless sort_by_relevance?
  end

  def sort_by_relevance?
    sort_by.nil? || sort_by == 'r'
  end

  def custom_filter_params?
    !default_sort? || tbs || since || self.until
  end

  def default_sort?
    sort_by.nil? || sort_by == default_sort_by
  end

  protected

  def initialize_date_attributes(options)
    @until = parse_until_ts(options[:until_date])
    @since = parse_since_ts(options[:since_date], @until)
    @created_until = parse_until_ts(options[:created_until_date])
    @created_since = parse_since_ts(options[:created_since_date], @created_until)

    flip_reversed_dates(@since, @until, @created_since, @created_until)

    return unless (@since.nil? && @until.nil?) || (@created_since.nil? && @created_until.nil?)

    time_based_search(options[:tbs])
  end

  def time_based_search(tbs)
    extent = TIME_BASED_SEARCH_OPTIONS[tbs]
    return unless extent

    @tbs = tbs
    @since = since_when(extent)
  end

  def flip_reversed_dates(since_date, until_date, created_since_date, created_until_date)
    if since_date && until_date && since_date > until_date
      @since = until_date.beginning_of_day
      @until = since_date.end_of_day
    elsif created_since_date && created_until_date && created_since_date > created_until_date
      @created_since = created_until_date.beginning_of_day
      @created_until = created_since_date.end_of_day
    end
  end

  def initialize_facet_attributes(options)
    @audience = options[:audience]
    @content_type = options[:content_type]
    @mime_type = options[:mime_type]
    @searchgov_custom1 = options[:searchgov_custom1]
    @searchgov_custom2 = options[:searchgov_custom2]
    @searchgov_custom3 = options[:searchgov_custom3]
    @tags = options[:tags]
  end

  def parse_until_ts(until_date_str)
    return if until_date_str.blank?

    parse_date_str(until_date_str).end_of_day
  rescue
    DateTime.current.end_of_day
  end

  def parse_since_ts(since_date_str, until_date)
    return if since_date_str.blank?

    parsed_date = begin
      parse_date_str(since_date_str).beginning_of_day
    rescue
      nil
    end
    parsed_date || (until_date || DateTime.current).prev_year.beginning_of_day
  end

  def parse_date_str(date_str)
    DateTime.strptime(date_str, I18n.t(:cdr_format)).utc
  end

  def since_when(extent)
    time = 1.send(extent).ago
    time = time.beginning_of_day if extent != :hour
    time
  end
end
