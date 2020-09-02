# frozen_string_literal: true

class ModuleSparklineQuery
  include AnalyticsDSL

  def initialize(affiliate_name)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      top_level_histogram_agg(json)
    end
  end

  def booleans(json)
    must_affiliate(json, affiliate_name)
    must_type(json, %w[search click])
    json.filter do
      json.child! { since(json, 'now-60d/d') }
      json.child! { json.exists { json.field 'modules' } }
    end
    must_not_spider(json)
  end

  def top_level_histogram_agg(json)
    json.aggs do
      json.agg do
        json.terms do
          json.field 'modules'
          json.size 100
        end
        histogram_type_agg(json)
      end
    end
  end

  def histogram_type_agg(json)
    json.aggs do
      json.histogram do
        json.date_histogram do
          json.field '@timestamp'
          json.interval 'day'
          json.format 'yyyy-MM-dd'
          json.min_doc_count 0
        end
        json.aggs do
          json.type do
            json.terms do
              json.field 'type'
            end
          end
        end
      end
    end
  end
end
