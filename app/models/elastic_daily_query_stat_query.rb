class ElasticDailyQueryStatQuery < ElasticTextFilteredQuery
  include DateRangeFilter

  def initialize(options)
    super(options)
    @highlighting = false
    @text_analyzer = 'snowball'
    @affiliate = options[:affiliate]
    @start_date = options[:start_date]
    @end_date = options[:end_date]
    self.highlighted_fields = %w(query)
  end

  def query(json)
    super(json)
    json.fields %w(:id)
  end

  def filtered_query_filter(json)
    json.filter do
      json.bool do
        must_affiliate_date_range(json, @affiliate, 'day', @start_date, @end_date)
      end
    end
  end

end