class ElasticDailyQueryStatQuery < ElasticTextFilteredQuery

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
        json.must do
          json.child! { json.term { json.affiliate @affiliate } }
          json.child! { date_filter(json) }
        end
      end
    end
  end

  def date_filter(json)
    json.range do
      json.day do
        json.gte @start_date
        json.lte @end_date
      end
    end
  end

end