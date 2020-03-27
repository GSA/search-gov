# frozen_string_literal: true

class TopQueryMatchQuery
  include AnalyticsDSL

  def initialize(affiliate_name, raw_query, start_date, end_date, agg_options = {})
    @affiliate_name, @raw_query, @start_date, @end_date = affiliate_name, raw_query, start_date, end_date
    @agg_options = agg_options
  end

  def body
    Jbuilder.encode do |json|
      query(json)
      terms_type_agg(json)
    end
  end

  def query(json)
    json.query do
      json.bool do
        match_query(json) if @raw_query.present?
        booleans(json)
      end
    end
  end

  def match_query(json)
    json.filter do
      json.child! do
        json.match do
          json.set! 'params.query' do
            json.query @raw_query
            json.analyzer 'snowball'
            json.operator 'and'
          end
        end
      end
    end
  end

  def booleans(json)
    must_affiliate(json, @affiliate_name)
    must_type(json, %w[search click])
    must_date_range(json, @start_date, @end_date)
    must_not_spider(json)
  end

  def terms_type_agg(json)
    json.aggs do
      json.agg do
        json.terms do
          @agg_options.each do |option, value|
            json.set! option, value
          end
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
