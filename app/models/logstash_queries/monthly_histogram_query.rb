class MonthlyHistogramQuery
  include AnalyticsDSL

  def initialize(affiliate_name, since)
    @affiliate_name = affiliate_name
    @since = since
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      date_histogram(json)
    end
  end

  def date_histogram(json)
    json.aggs do
      json.agg do
        json.date_histogram do
          json.field "@timestamp"
          json.interval 'month'
          json.format 'yyyy-MM'
          json.min_doc_count 0
        end
      end
    end
  end

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { since(json, @since) }
    end
    must_not_spider(json)
  end

end