class TopQueryMatchQuery
  include DateRangeFilter

  def initialize(affiliate_name, raw_query, start_date, end_date, agg_options = {})
    @affiliate_name, @raw_query, @start_date, @end_date = affiliate_name, raw_query, start_date, end_date
    @agg_options = agg_options
  end

  def body
    Jbuilder.encode do |json|
      query(json)
      terms_agg(json)
    end
  end

  def query(json)
    json.query do
      json.filtered do
        json.query do
          json.match do
            json.query do
              json.query @raw_query
              json.analyzer "snowball"
              json.operator "and"
            end
          end
        end if @raw_query.present?
        json.filter do
          json.bool do
            booleans(json)
          end
        end
      end
    end
  end

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { date_range(json, '@timestamp', @start_date, @end_date) }
    end
    json.must_not do
      json.term { json.set! "useragent.device", "Spider" }
    end
  end

  def terms_agg(json)
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
              json.field "type"
            end
          end
        end
      end
    end
  end

end
