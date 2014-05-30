class MonthlyHistogramQuery < TopNQuery

  def initialize(affiliate_name, since)
    super(affiliate_name)
    @since = since
  end

  def terms_agg(json)
    json.aggs do
      json.agg do
        json.date_histogram do
          json.field "@timestamp"
          json.interval 'month'
          json.format 'yyyy-MM'
        end
      end
    end
  end

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { since(json) }
    end
    json.must_not do
      json.term { json.set! "useragent.device", "Spider" }
    end
  end

  private
  def since(json)
    json.range do
      json.set! "@timestamp" do
        json.gte @since
      end
    end
  end

end