# frozen_string_literal: true

class MonthlyHistogramQuery
  include AnalyticsDsl
  RTU_START_DATE = '2014-06-01'

  def initialize(affiliate_name, since = RTU_START_DATE)
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
          json.field '@timestamp'
          json.interval 'month'
          json.format '8yyyy-MM'
          json.min_doc_count 0
        end
      end
    end
  end

  def booleans(json)
    must_affiliate(json, affiliate_name)
    must_type(json, 'search')
    json.filter do
      json.child! { since(json, @since) }
    end
    must_not_spider(json)
  end
end
